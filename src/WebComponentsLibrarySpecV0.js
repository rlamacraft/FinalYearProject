/*
* This library allow for Web Components, both presentation components and other, to be defined
* in a spec agnostic manner so that when V1 spec is fully supported this library may be replaced
* with a version targeted at V1 of the spec rather than V0 as this is.
*/


/*
* This will register a component. In this implementation the Class will
* be decomposed, by V1 of the spec will use the Class directly in the definition.
* 'Class' must be a class defintion, that extends HTML Element (see above defintion),
* as well as provide a getter for the template.
*/
const RegisterComponent = function(commandName, functions) {

  const setMutationObserver = function(target) {
    // create an observer instance
    this.observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        functions.onContentChange(mutation.target);
      });
    });

    // configuration of the observer:
    var config = { attributes: true, childList: true, characterData: true };

    // pass in the target node, as well as the observer options
    this.observer.observe(target, config);
  }

  const proto = Object.create(HTMLElement.prototype);

  proto.createdCallback = function() {
    const template = document.getElementById(`${commandName}_import`).import.getElementById(`${commandName}_template`);
    const root = this.createShadowRoot();
    const clone = document.importNode(template.content, true);
    root.appendChild(clone);
    correctSlot(root);
    setMutationObserver(this);
  }

  proto.detachedCallback = function() {
    this.observer.disconnect();
  }

  document.registerElement(`pres-${commandName}`, {
    prototype: proto
  });
}

/* Corrects the slot used in the HTML template to fit v1 with a content tag that fits v0 */
function correctSlot(component) {
  const slot = component.querySelector('slot[name="content"]');
  const contentSlot = document.createElement("content");
  slot.appendChild(contentSlot);
}

/* This does nothing and is just a placeholder */
function setup(commandName, element) {}
