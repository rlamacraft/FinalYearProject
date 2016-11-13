var assert = require('assert');
var parser = require("../src/parser.js")
describe('Parser', function() {
  describe('empty string', function() {
    it('should return an empty string', function() {
      assert.equal("", parser.parse(""));
    });
  });
  describe('some string: "foo"', function() {
    it('should return an array of a single object that represents the string: {name:"_string", .. rawContent:"foo"}', function() {
      assert.deepStrictEqual([{name : "_string", content : [], rawContent : "foo"}], parser.parse("foo"));
    });
  });
  describe('some command: "\\title{Example}"', function() {
    it('should return an array of a single object that represents the command: {name:"title", content:[{name:"_string", content:[], rawContent:"Example"}], rawContent:""}', function() {
      assert.deepStrictEqual([{name : "title", content : [{name:"_string", content:[], rawContent:"Example"}], rawContent : "Example"}], parser.parse("\\title{Example}"));
    });
  });
});
