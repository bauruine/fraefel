// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//netscape.security.PrivilegeManager.enablePrivilege("UniversalFileRead");

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
});
