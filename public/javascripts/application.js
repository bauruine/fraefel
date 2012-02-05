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

  $('div[data-type=modal]').dialog({ autoOpen: false, modal: true, draggable: false, resizable: false, width: 'auto' });
  
  $('a[data-type=modal]').click(function() {
    var remote_url = $(this).attr("href");
    $('div[data-type=modal]').load(remote_url + ' form');
    if ($(this).attr('data-modal_width') != undefined) {
      $( "div[data-type=modal]" ).dialog( "option", "width", 500 );
    };
    $('div[data-type=modal]').dialog('open');
    $('div[data-type=modal]').dialog("option", "position", "center");
    
    return false;
  });
  
  $('a[data-type=modal_index]').click(function() {
    var remote_url = $(this).attr("href");
    $('div[data-type=modal]').load(remote_url + ' table');
    if ($(this).attr('data-modal_width') != undefined) {
      $( "div[data-type=modal]" ).dialog( "option", "width", 1424 );
    };
    $('div[data-type=modal]').dialog('open');
    $('div[data-type=modal]').dialog("option", "position", "center");
    
    return false;
  });
  
  $('a[data-role="dialog-remote"]').click(function() {
    $('.dialog').show();
    
    $('.dialog').dialog('open');
    return false;
  });
  
  $(window).resize(function() {
    $('div[data-type=modal]').dialog("option", "position", "center");
  });
  
  if ($('form[data-submit_handler=true]').size() != 0) {
    $("form[data-submit_handler=true]").find($("input[type=submit]")).attr('disabled', 'disabled');
    
    $("form[data-submit_handler=true]").find($("input[type=checkbox]")).change(function(){
      if ($("form[data-submit_handler=true]").find($("input[type=checkbox]:checked")).length >= 1) {
        $("form[data-submit_handler=true]").find($("input[type=submit]")).removeAttr('disabled');
      } else {
        $("form[data-submit_handler=true]").find($("input[type=submit]")).attr('disabled', 'disabled');
      };
    });
    
  };
  
  if ($("form[data-tab]").size() != 0) {
    $("form:not([data-tab=filter])").hide()
  };
  
  $("a[data-type=tab]").click(function() {
    var warpToTab = $(this).attr("data-warp");
    var currentForm = $("form[data-tab]")
    $("form:not(:hidden)").hide();
    $("form[data-tab=" + warpToTab + "]").show();
    return false;
  });
  
  $('input#delivery_rejection_customer_company').autocomplete({
    source: $('input#delivery_rejection_customer_company').data("autocomplete_source")
  });
  
  /*
  if ($(".section.endless")) {
    var num_pages = $("tbody#purchase_orders").attr("data-num-pages");
    var data_params = $("tbody#purchase_orders").attr("data-params").length ? "/purchase_orders?" + $("tbody#purchase_orders").attr("data-params") + "&" : "/purchase_orders?";
    for (var i=2; i <= parseInt(num_pages); i++) {
      var url = data_params + 'page=' + i
      $.getScript(url);
    };
  };
  */
  /*
  if ($("nav.pagination").length) {
    $("nav.pagination").hide();
    $(window).scroll(function () {
      var url = $("nav.pagination span.next a").attr('href');
      if (url && $(window).scrollTop() > ($(document).height() - $(window).height() - 50)) {
        $("nav.pagination").text("Fetching...");
        $.getScript(url);
      };
    });
  };
  */
  
});
