/*
 * Parses unix mail boxes into headers and bodies.
 */

%%{
        machine MailboxScanner;

        # Buffer the header names.
        action bufHeadName { this.headName.push(String.fromCharCode(fc)); }

        # Prints a blank line after the end of the headers of each message.
        action blankLine { sys.print("\n"); }
        
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

        action hchar { this.headContent.push(String.fromCharCode(fc));}
        action hspace {this.headContent.push(' ');}

        action hfinish {
                console.log(this.headContent.join(''));
                this.headContent = [];
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
                var header = this.headName.join('');
                if (header === "From" || header === "To" || header === "Subject")
                {
                        /* Print the header name, then jump to a machine the will display
                         * the contents. */
                        sys.print(header + ':');
                        this.headName = [];
                        fcall printHeader;
                }

                this.headName = [];
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

%% access this.;
%% variable data data;

const BUFSIZE = 2048; 
const fs = require('fs');
const sys = require('sys');

function MailboxScanner() {
  this.headName = [];
  this.headContent = [];

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

MailboxScanner.prototype.execute = function(data, isEof) {
  /*
   * See TODO above.
   */
  var p = 0;
  var pe = data.length;
  var eof = isEof ? pe : 0;

  %% write exec;

  if (this.cs == MailboxScanner_error) {
    return -1;
  }

  if (this.cs >= MailboxScanner_first_final) {
    return -1;
  }

  return 0;
};

MailboxScanner.prototype.finish = function() {
  if (this.cs == MailboxScanner_error) {
    return -1;
  }

  if (this.cs >= MailboxScanner_first_final) {
    return 1;
  }

  return 0;
};

var read = 0;
const FILE_SIZE = 808659;

var buf = new Buffer(4096);
var scanner = new MailboxScanner();

fs.open('sample.mbox', 'r', function(e, fd) {
  if (e) throw e;

  function passOn(e, bytes) {
    if (e) throw e;

    scanner.execute(buf);
    read += bytes;

    if (read === FILE_SIZE) {
      var rv = scanner.finish();
      console.log('Scanner returned ' + rv);

      return;
    }

    fs.read(fd, buf, 0, 4096, null, passOn);
  }

  fs.read(fd, buf, 0, 4096, null, passOn);
});
