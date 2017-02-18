/*
* This will register a component. In this implementation the Class will
* be used Class directly in the definition.
* 'Class' must be a class defintion, that extends HTML Element (see above defintion),
* as well as provide a getter for the template.
*/
const RegisterComponent = function(commandName, functions) {
  if(typeof(functions) === "undefined")
    functions = {};

  const setMutationObserver = function(target) {
    // create an observer instance
    this.observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        functions.onContentChange(mutation);
      });
    });

    // configuration of the observer:
    var config = { attributes: true, childList: true, characterData: true };

    // pass in the target node, as well as the observer options
    this.observer.observe(target, config);
  };

  window.customElements.define(`pres-${commandName}`, class extends HTMLElement {
    constructor() {
      super();
      setup(commandName, this);

      if(typeof(functions.onStart) === "function") {
        functions.onStart(this);
      }
      //these are for when the content of the component changes (which includes Elm adding the original content)
      if(typeof(functions.onContentChange) === "function") {
        setMutationObserver(this);
      }
    }
  });
}

// TODO: When component is detached i.e. removed from the DOM, the observer needs to be disconnected
//    this.observer.disconnect();

/*
* Sets up the shadow DOM, in the v0 this is done by RegisterComponent
* but in v1 this is done in the class constructor
*/
function setup(commandName, element) {
  const shadowRoot = element.attachShadow({mode : 'open'});
  // const template = document.currentScript.ownerDocument.getElementById(`${commandName}_template`);
  const template = document.getElementById(`${commandName}_import`).import.getElementById(`${commandName}_template`);
  shadowRoot.appendChild(template.content.cloneNode(true));
}
