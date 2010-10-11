/*
 * Parses unix mail boxes into headers and bodies.
 *
 * This file was translated to JavaScript from mailbox.cc.
 */

%%{
        machine MailboxScanner;

        # Buffer the header names.
        action bufHeadName {
          this.appendHeader(fc);
        }

        # Prints a blank line after the end of the headers of each message.
        action blankLine {
          this.newline();
        }
        
        # Helpers we will use in matching the date section of the from line.
        day = /[A-Z][a-z][a-z]/;
        month = /[A-Z][a-z][a-z]/;
        year = /[0-9][0-9][0-9][0-9]/;
        time = /[0-9][0-9]:[0-9][0-9]/ . ( /:[0-9][0-9]/ | '' );
        letterZone = /[A-Z][A-Z][A-Z]/;
        numZone = /[+\-][0-9][0-9][0-9][0-9]/;
        zone = letterZone | numZone;
        dayNum = /[0-9 ][0-9]/;

        # These are the different formats of the date minus an obscure
        # type that has a funny string 'remote from xxx' on the end. Taken
        # from c-client in the imap-2000 distribution.
        date = day . ' ' . month . ' ' . dayNum . ' ' . time . ' ' .
                ( year | year . ' ' . zone | zone . ' ' . year );

        # From lines separate messages. We will exclude fromLine from a message
        # body line.  This will cause us to stay in message line up until an
        # entirely correct from line is matched.
        fromLine = 'From ' . (any-'\n')* . ' ' . date . '\n';

        # The types of characters that can be used as a header name.
        hchar = print - [ :];

        # Simply eat up an uninteresting header. Return at the first non-ws
        # character following a newline.
        consumeHeader := ( 
                        [^\n] | 
                        '\n' [ \t] |
                        '\n' [^ \t] @{fhold; fret;}
                )*;

        action hchar {
          this.appendContent(fc);
        }
        action hspace {
          this.appendContent(' ');
        }

        action hfinish {
          this.printContent();
          this.resetContent();
          
          fhold;
          fret;
        }

        # Display the contents of a header as it is consumed. Collapses line
        # continuations to a single space. 
        printHeader := ( 
                [^\n] @hchar  | 
                ( '\n' ( [ \t]+ '\n' )* [ \t]+ ) %hspace
        )** $!hfinish;

        action onHeader 
        {
                var header = this.headerToString();
                if (header === "From" || header === "To" || header === "Subject")
                {
                  this.printHeader();

                  fcall printHeader;
                }
                this.resetHeader();

                fcall consumeHeader;
        }

        header = hchar+ $bufHeadName ':' @onHeader;

        # Exclude fromLine from a messageLine, otherwise when encountering a
        # fromLine we will be simultaneously matching the old message and a new
        # message.
        messageLine = ( [^\n]* '\n' - fromLine );

        # An entire message.
        message = ( fromLine .  header* .  '\n' @blankLine .  messageLine* );

        # File is a series of messages.
        main := message*;

}%%

%% write data;

//
// All state should be held as propeties of the current object and accessed
// via 'this.'.
//
%% access this.;
//
// The input data is pass as an argument to the execute function so override
// how it is accessed.
//
%% variable data data;

const BUFSIZE = 2048;

function Mailbox(outStream) {
  this.headerBytes = 0;
  this.header = new Buffer(BUFSIZE);

  this.contentBytes = 0;
  this.content = new Buffer(BUFSIZE);

  this.outStream = outStream;

  // %% write init;

  /* TODO XXX
   * This should be using %% write init.
   *
   * For reasons I haven't explored yet, write init wants to assign the
   * p and pe variables. In particular, it wants to assign pe to the value
   * of data.length. This doesn't exist yet (see .execute()). To work
   * around this implement %% write init by other means until I've decided
   * which part of the software is to blame.
   */
  this.top = 0;
  this.stack = [];
  this.cs = MailboxScanner_start;
}

Mailbox.prototype.appendHeader = function(byte) {
  this.header[this.headerBytes] = byte;
  this.headerBytes += 1;
};

Mailbox.prototype.appendContent = function(byte) {
  this.content[this.contentBytes] = byte;
  this.contentBytes += 1;
};

Mailbox.prototype.execute = function(data) {
  /*
   * See TODO above.
   */
  var p = 0;
  var pe = data.length;
  var eof = pe;

  %% write exec;

  return this.checkState();
};

Mailbox.prototype.finish = function() {
  return this.checkState();
};

Mailbox.prototype.checkState = function() {
  if (this.cs == MailboxScanner_error) {
    throw new Error('Scanner error!');

    return -1;
  }

  if (this.cs >= MailboxScanner_first_final) {
    return 1;
  }

  return 0;
};

Mailbox.prototype.headerToString = function() {
  return this.header.toString('ascii', 0, this.headerBytes);
};

Mailbox.prototype.newline = function() {
  this.outStream.write("\n");
};

Mailbox.prototype.printContent = function() {
  this.outStream.write(this.content.slice(0, this.contentBytes));
  this.newline();
};

Mailbox.prototype.printHeader = function() {
  this.outStream.write(this.header.slice(0, this.headerBytes));
  this.outStream.write(': ');
};

Mailbox.prototype.resetHeader = function() {
  this.headerBytes = 0;  
};

Mailbox.prototype.resetContent = function() {
  this.contentBytes = 0;
};

//
// Main.
//

var scanner = new Mailbox(process.stdout);

var stdin = process.openStdin();

stdin.on('data', function(buf) {
  scanner.execute(buf);
});

stdin.on('end', function() {
  console.log('Scanner returned: ' + scanner.finish());
});
