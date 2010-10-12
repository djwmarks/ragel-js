%%{
  #
  # Parse the HTTP Cookie header.
  #

  machine http_cookie;

  action on_cookie_name_char {
    this.nameBuffer[this.nameLength] = fc;
    this.nameLength += 1;
  }

  action on_cookie_value_char {
    this.valueBuffer[this.valueLength] = fc;
    this.valueLength += 1;
  }

  action on_cookie {
    var name = this.nameBuffer.toString('utf8', 0, this.nameLength);
    var value = this.valueBuffer.toString('utf8', 0, this.valueLength);

    this.nameLength = 0;
    this.valueLength = 0;

    this.cookies[name] = value;
  }

  action on_done {
    console.log(this.cookies);
  }

  header = 'Cookie:';

  name_char = (alnum ('-' | alnum)*) $on_cookie_name_char;
  name = name_char+;

  value_char = ((alnum | punct) - ';') $on_cookie_value_char;
  value = value_char+ ';';

  cookie = name '=' value @on_cookie;

  cookies = cookie (' ' cookie)*;

  main := header ' ' cookies;
}%%

%% write data;
%% access this.;

//
// NOTE: This is entirely contrived example. Don't assume this is better than
// a handwritten script. The power of Ragel is more obvious with more complex
// formats.
//
function CookieReader() {
  const BUFFER_SIZE = 4096;

  this.data = new Buffer(BUFFER_SIZE);

  this.nameLength = 0;
  this.nameBuffer = new Buffer(BUFFER_SIZE);

  this.valueLength = 0;
  this.valueBuffer = new Buffer(BUFFER_SIZE);

  this.cookies = {};

  %% write init;
}

CookieReader.prototype.parse = function(data) {
  //
  // Ragel works in bytes, not characters. Use Node's Buffer object to convert.
  //
  this.data.write(data);

  var p = 0;
  var pe = Buffer.byteLength(data);
  var eof = 0;

  %% write exec;
};

var reader = new CookieReader();
reader.parse("Cookie: NAME1=VALUE1; NAME2=VALUE2; NAME3=VALUE3");

console.log(reader.cookies);
