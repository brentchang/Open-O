/*
	Copyright (c) 2004-2006, The Dojo Foundation
	All Rights Reserved.

	Licensed under the Academic Free License version 2.1 or above OR the
	modified BSD license. For more information on Dojo licensing, see:

		http://dojotoolkit.org/community/licensing.shtml
*/

dojo.provide("dojo.cal.textDirectory");
dojo.require("dojo.string");

dojo.cal.textDirectory.Property = function (/*String*/line) {
// summary: parses a single line from an iCalendar text/directory file
// and creates an object with four named values; name, group, params
// and value. name, group and value are strings containing the original
// tokens unaltered and values is an array containing name/value pairs
// or a single name token packed into arrays.

    // split into name/value pair
    var left = dojo.string.trim(line.substring(0, line.indexOf(':')));
    var right = dojo.string.trim(line.substr(line.indexOf(':') + 1));

    // separate name and paramters
    var parameters = dojo.string.splitEscaped(left, ';');
    this.name = parameters[0];
    parameters.splice(0, 1);

    // parse paramters
    this.params = [];
    var arr;
    for (var i = 0; i < parameters.length; i++) {
        arr = parameters[i].split("=");
        var key = dojo.string.trim(arr[0].toUpperCase());

        if (arr.length == 1) {
            this.params.push([key]);
            continue;
        }

        var values = dojo.string.splitEscaped(arr[1], ',');
        for (var j = 0; j < values.length; j++) {
            if (dojo.string.trim(values[j]) != '') {
                this.params.push([key, dojo.string.trim(values[j])]);
            }
        }
    }

    // separate group
    if (this.name.indexOf('.') > 0) {
        arr = this.name.split('.');
        this.group = arr[0];
        this.name = arr[1];
    }

    // don't do any parsing, leave to implementation
    this.value = right;
}


dojo.cal.textDirectory.tokenise = function (/*String*/text) {
// summary: parses text into an array of properties.

    // normlize to one property per line and parse
    var nText = dojo.string.normalizeNewlines(text, "\n").replace(/\n[ \t]/g, '').replace(/\x00/g, '');

    var lines = nText.split("\n");
    var properties = [];

    for (var i = 0; i < lines.length; i++) {
        if (dojo.string.trim(lines[i]) == '') {
            continue;
        }
        var prop = new dojo.cal.textDirectory.Property(lines[i]);
        properties.push(prop);
    }
    return properties; // Array
}
