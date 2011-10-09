// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//netscape.security.PrivilegeManager.enablePrivilege("UniversalFileRead");

if (navigator.appName == "Microsoft Internet Explorer") {
	var ua = navigator.userAgent;
	var re = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
	var rv = parseFloat(re.exec(ua)[1]);
	if (rv < 9) {
		document.createElement('header');
		document.createElement('hgroup');
		document.createElement('nav');
		document.createElement('menu');
		document.createElement('section');
		document.createElement('article');
		document.createElement('aside');
		document.createElement('footer');
	};
};

$(document).ready(function(){
  //netscape.security.PrivilegeManager.enablePrivilege("UniversalBrowserRead");
  //netscape.security.PrivilegeManager.enablePrivilege("UniversalFileRead");
  $('a.openDatabase').click(function(){
    try {
      netscape.security.PrivilegeManager.enablePrivilege("UniversalFileRead");
    } catch (err) {   
      document.write("Sorry, you can not enjoy this site because of " +err+ ".");
      return false;
    }
      window.open('file:///' + $(this).attr("data-link"));
      return true;
  });

	$('.date_picker').datepicker({ dateFormat: 'yy-mm-dd' });

	$('div[data-type=modal]').dialog({ autoOpen: false, modal: true, draggable: false, resizable: false });
	
	$('a[data-type=modal]').click(function() {
		var remote_url = $(this).attr("href");
		$('div[data-type=modal]').load(remote_url + ' form');
		$('div[data-type=modal]').dialog('open');
		return false;
	});
});
