
/* line 1 "http_cookie.rl" */

/* line 45 "http_cookie.rl" */



/* line 9 "http_cookie.js" */
const _http_cookie_actions = [
	0, 1, 0, 1, 1, 1, 2
];

const _http_cookie_key_offsets = [
	0, 0, 1, 2, 3, 4, 5, 6, 
	7, 8, 14, 22, 26, 29
];

const _http_cookie_trans_keys = [
	67, 111, 111, 107, 105, 101, 58, 32, 
	48, 57, 65, 90, 97, 122, 45, 61, 
	48, 57, 65, 90, 97, 122, 33, 58, 
	60, 126, 59, 33, 126, 32, 0
];

const _http_cookie_single_lengths = [
	0, 1, 1, 1, 1, 1, 1, 1, 
	1, 0, 2, 0, 1, 1
];

const _http_cookie_range_lengths = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 3, 3, 2, 1, 0
];

const _http_cookie_index_offsets = [
	0, 0, 2, 4, 6, 8, 10, 12, 
	14, 16, 20, 26, 29, 32
];

const _http_cookie_indicies = [
	0, 1, 2, 1, 3, 1, 4, 1, 
	5, 1, 6, 1, 7, 1, 8, 1, 
	9, 9, 9, 1, 9, 10, 9, 9, 
	9, 1, 11, 11, 1, 12, 11, 1, 
	8, 1, 0
];

const _http_cookie_trans_targs = [
	2, 0, 3, 4, 5, 6, 7, 8, 
	9, 10, 11, 12, 13
];

const _http_cookie_trans_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 3, 5
];

const http_cookie_start = 1;
const http_cookie_first_final = 13;
const http_cookie_error = 0;

const http_cookie_en_main = 1;


/* line 48 "http_cookie.rl" */

/* line 49 "http_cookie.rl" */

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

  
/* line 89 "http_cookie.js" */
{
	  this.cs = http_cookie_start;
} /* JSCodeGen::writeInit */

/* line 69 "http_cookie.rl" */
}

CookieReader.prototype.parse = function(data) {
  //
  // Ragel works in bytes, not characters. Use Node's Buffer object to convert.
  //
  this.data.write(data);

  var p = 0;
  var pe = Buffer.byteLength(data);
  var eof = 0;

  
/* line 108 "http_cookie.js" */
{
	var _klen, _trans, _keys, _ps, _widec, _acts, _nacts;
	var _goto_level, _resume, _eof_trans, _again, _test_eof;
	var _out;
	_klen = _trans = _keys = _acts = _nacts = null;
	_goto_level = 0;
	_resume = 10;
	_eof_trans = 15;
	_again = 20;
	_test_eof = 30;
	_out = 40;
	while (true) {
	_trigger_goto = false;
	if (_goto_level <= 0) {
	if (p == pe) {
		_goto_level = _test_eof;
		continue;
	}
	if ( this.cs == 0) {
		_goto_level = _out;
		continue;
	}
	}
	if (_goto_level <= _resume) {
	_keys = _http_cookie_key_offsets[ this.cs];
	_trans = _http_cookie_index_offsets[ this.cs];
	_klen = _http_cookie_single_lengths[ this.cs];
	_break_match = false;
	
	do {
	  if (_klen > 0) {
	     _lower = _keys;
	     _upper = _keys + _klen - 1;

	     while (true) {
	        if (_upper < _lower) { break; }
	        _mid = _lower + ( (_upper - _lower) >> 1 );

	        if ( this.data[p] < _http_cookie_trans_keys[_mid]) {
	           _upper = _mid - 1;
	        } else if ( this.data[p] > _http_cookie_trans_keys[_mid]) {
	           _lower = _mid + 1;
	        } else {
	           _trans += (_mid - _keys);
	           _break_match = true;
	           break;
	        };
	     } /* while */
	     if (_break_match) { break; }
	     _keys += _klen;
	     _trans += _klen;
	  }
	  _klen = _http_cookie_range_lengths[ this.cs];
	  if (_klen > 0) {
	     _lower = _keys;
	     _upper = _keys + (_klen << 1) - 2;
	     while (true) {
	        if (_upper < _lower) { break; }
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1);
	        if ( this.data[p] < _http_cookie_trans_keys[_mid]) {
	          _upper = _mid - 2;
	         } else if ( this.data[p] > _http_cookie_trans_keys[_mid+1]) {
	          _lower = _mid + 2;
	        } else {
	          _trans += ((_mid - _keys) >> 1);
	          _break_match = true;
	          break;
	        }
	     } /* while */
	     if (_break_match) { break; }
	     _trans += _klen
	  }
	} while (false);
	_trans = _http_cookie_indicies[_trans];
	 this.cs = _http_cookie_trans_targs[_trans];
	if (_http_cookie_trans_actions[_trans] != 0) {
		_acts = _http_cookie_trans_actions[_trans];
		_nacts = _http_cookie_actions[_acts];
		_acts += 1;
		while (_nacts > 0) {
			_nacts -= 1;
			_acts += 1;
			switch (_http_cookie_actions[_acts - 1]) {
case 0:
/* line 8 "http_cookie.rl" */

    this.nameBuffer[this.nameLength] =  this.data[p];
    this.nameLength += 1;
  		break;
case 1:
/* line 13 "http_cookie.rl" */

    this.valueBuffer[this.valueLength] =  this.data[p];
    this.valueLength += 1;
  		break;
case 2:
/* line 18 "http_cookie.rl" */

    var name = this.nameBuffer.toString('utf8', 0, this.nameLength);
    var value = this.valueBuffer.toString('utf8', 0, this.valueLength);

    this.nameLength = 0;
    this.valueLength = 0;

    this.cookies[name] = value;
  		break;
/* line 215 "http_cookie.js" */
			} /* action switch */
		}
	}
	if (_trigger_goto) {
		continue;
	}
	}
	if (_goto_level <= _again) {
	if ( this.cs == 0) {
		_goto_level = _out;
		continue;
	}
	p += 1;
	if (p != pe) {
		_goto_level = _resume;
		continue;
	}
	}
	if (_goto_level <= _test_eof) {
	}
	if (_goto_level <= _out) {
		break;
	}
	}
	}

/* line 82 "http_cookie.rl" */
};

var reader = new CookieReader();
reader.parse("Cookie: NAME1=VALUE1; NAME2=VALUE2; NAME3=VALUE3");

console.log(reader.cookies);
