/**
 * Get the host of the this script. The host will be used for posting the data.
 */
var getHost = function () {
    var scripts = document.getElementsByTagName("script");
    var i;
    for (i = 0; i < scripts.length; i++) {
        var urlAttribute = scripts[i].attributes.getNamedItem("src");
        if (urlAttribute) {
            var url = urlAttribute.nodeValue;
            if (typeof url != 'undefined' && url.indexOf("revinate-form") != -1) {
                var parser = document.createElement("a");
                parser.href = url;
                if (parser.host.indexOf('inguest.com') != -1) {
                    return parser.host;
                }
            }
        }
    }
    return "contact-api.inguest.com";
};

/**
 * Get Submit button from Revinate sign up form. It's used in onSubmit event handler.
 * @returns {Element}|undefined
 */
var getSubmitButton = function(doc) {
    var elements = doc.getElementsByTagName("button");
    var i;
    for (i = 0; i < elements.length; i++) {
        if (elements[i].attributes.getNamedItem("type").nodeValue == "submit") {
            return elements[i];
        }
    }
    return undefined;
};

/**
 * Get and format form data
 * @return {Object}
 * {"tokens":["token1" ...], "contacts":[{"firstname":"myFirst", "email":"my@e.mail"} ...]}
 */
var getFormData = function (form, token) {
    var inputs = Array.prototype.slice.call(form.getElementsByTagName("input"));
    var selects = Array.prototype.slice.call(form.getElementsByTagName("select"));
    var textareas = Array.prototype.slice.call(form.getElementsByTagName("textarea"));
    var elements = [].concat(inputs, selects, textareas);
    var data = {tokens: [token], contacts: []};
    var contact = {};
    var i = 0;
    for (i = 0; i < elements.length; i++) {
        switch (elements[i].nodeName) {
            case 'INPUT':
                if (elements[i].type == 'checkbox') {
                    contact[elements[i].name] = elements[i].checked;
                    break;
                }
            /* else go to default*/
            case 'SELECT':
                if (elements[i].type == 'select-multiple') {
                    var j = 0;
                    var selected = [];
                    for (j = 0; j < elements[i].options.length; j++) {
                        if (elements[i].options[j].selected) {
                            selected.push(elements[i].options[j].value);
                        }
                    }
                    contact[elements[i].name] = selected;
                    break;
                }
            /* else go to default*/
            default:
                var group = elements[i].getAttribute('data-group');
                var delimiter = elements[i].getAttribute('data-delimiter');
                var elementName = elements[i].name;
                var elementValue = elements[i].value;

                if (group) {
                    if (!elementValue) {
                        break;
                    }

                    if (contact.hasOwnProperty(group)) {
                        contact[group] += elementValue;
                    } else {
                        contact[group] = elementValue;
                    }

                    if (delimiter) {
                        contact[group] += delimiter;
                    }
                    break;
                }
                contact[elementName] = elementValue;
        }
    }
    data.contacts = [contact];
    return data;
};

/**
 * Revinate form onSubmit event handler
 * @constructor
 */
var revFormOnSubmit = function() {
    var form = document.getElementById("revinate_contact_api_form");
    var token = form.attributes.getNamedItem('token').nodeValue;
    var data = getFormData(form, token);
    if (typeof data.contacts[0].email == 'undefined' || data.contacts[0].email == "") {
        return;
    }
    var url = "https://" + getHost() + "/api/add-contacts-to-lists";
    var xhr = window.XMLHttpRequest ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");

    // asynchronous event
    var button = getSubmitButton(form);
    button.disabled = true;
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.DONE) {
            if(xhr.status == 200){
                if (typeof button != 'undefined') {
                    button.innerHTML = "Submitted";
                    button.disabled = true;

                }
            } else {
                if (typeof button != 'undefined') {
                    button.innerHTML = "Failed";
                    button.disabled = false;
                }
            }
        }
    };

    // post data
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "text/plain");
    var payload = JSON.stringify(data);
    xhr.send(payload);
};