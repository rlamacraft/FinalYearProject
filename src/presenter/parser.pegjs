{
  function generateParsedStatement(name, content, rawContent) {
    if( name.length < 1)
      throw "Invalid name for generating a Parsed Statement.";
    return {
      name  : name,
      content : content,
      rawContent: rawContent
    };
  }

  /*
    Generates the raw content of a command, which is used by some components.
    Must be done as part of parsing as some information is lost when parsing.
  */
  function getRaw(statements) {
    let rawContent = "";
    for( let eachStatement of statements) {
      if(eachStatement.name === "_string") {
        rawContent += eachStatement.rawContent;
      } else {
        rawContent += "\\" + eachStatement.name + "{" + eachStatement.rawContent + "}\n";
      }
    }
    return rawContent;
  }
}

start
  = statement*

statement
  = ind:indentation thing:command newLines {return thing} / ind:indentation thing:stringStatement {return thing}

command
  = "\\" name:identifier "{" newLines? content:(statement*) "}" { return generateParsedStatement(name, content, getRaw(content)) }

stringStatement
  = value:generalString returns:newLines { return generateParsedStatement("_string", [], value + returns) }

identifier /* identifies beginning with an underscore are private */
  = chars:[a-z]+ { return chars.join("") }

generalString
  = chars:[^\\{}\n]+ { return chars.join("") }

indentation
  = [ \t\r\n]* { return "" } /* ignore indentation whitespace */

newLines
  = lines:"\n"*  { return (lines.length === 0 ? "" : "\n") } /* ignore any blanks */
