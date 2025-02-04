/*
	Copyright (c) 2004-2006, The Dojo Foundation
	All Rights Reserved.

	Licensed under the Academic Free License version 2.1 or above OR the
	modified BSD license. For more information on Dojo licensing, see:

		http://dojotoolkit.org/community/licensing.shtml
*/

dojo.require("dojo.experimental");

dojo.experimental("dojo.data.old.*");
dojo.kwCompoundRequire({
    common: [
        "dojo.data.old.Item",
        "dojo.data.old.ResultSet",
        "dojo.data.old.provider.FlatFile"
    ]
});
dojo.provide("dojo.data.old.*");

