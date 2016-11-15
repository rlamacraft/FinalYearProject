const attachShadowDOM = function(thisThing, template) {
  const shadowRoot = thisThing.attachShadow({mode : 'open'});
  shadowRoot.appendChild(template.content.cloneNode(true));
}
