var assert = require('assert');
var parser = require("../../src/presenter/parser.js")
describe('Parser', function() {
  describe('empty string', function() {
    it('should return: ""', function() {
      assert.equal("", parser.parse(""));
    });
  });
  describe('some string: "foo"', function() {
    it('should return: [{name:"_string", content:[], rawContent:"foo"}]', function() {
      assert.deepStrictEqual([{name : "_string", content : [], rawContent : "foo"}], parser.parse("foo"));
    });
  });
  describe('an empty command: "\\foo{}"', function() {
    it('should return: [{name:"foo", content:[], rawContent:""}]', function() {
      assert.deepStrictEqual([{name: "foo", content: [], rawContent: ""}], parser.parse("\\foo{}"));
    });
  });
  describe('some command: "\\title{Example}"', function() {
    it('should return: [{name:"title", content:[{name:"_string", content:[], rawContent:"Example"}], rawContent:"Example"}]', function() {
      assert.deepStrictEqual([{name : "title", content : [{name:"_string", content:[], rawContent:"Example"}], rawContent : "Example"}], parser.parse("\\title{Example}"));
    });
  });
  describe('a nested command: "\\parentcomponent{\\childcommand{}}"', function() {
    it('should return: [{name:"parentcomponent", content:[{name:"childcommand", content: [], rawContent: ""}], rawContent: "\\childcommand{}\\n"}]', function() {
      assert.deepStrictEqual([{name: "parentcomponent", content: [{name: "childcommand", content: [], rawContent: ""}], rawContent: "\\childcommand{}\n"}], parser.parse("\\parentcomponent{\\childcommand{}}"));
    })
  })
});
