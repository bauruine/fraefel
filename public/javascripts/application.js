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
  
  $('a[data-show-tooltip="true"]').qtip({
    position: {
       my: 'bottom center',
       at: 'top center',
       adjust: {
          method: "filp",
          x: 0,
          y: 0
       }
    },
    style: {
       classes: 'ui-tooltip-youtube'
    }
  });

  $('.date_picker').datepicker({ dateFormat: 'yy-mm-dd' });
  
  $('div[data-type="modal"], div[data-type="modal2"]').dialog({
    autoOpen: false,
    width: 'auto',
    height: 'auto',
    modal: true
  });
  
  $('a[data-role="table_remote"]').click(function() {
    var remote_url = $(this).attr("href");
    $('div[data-type=modal]').load(remote_url + ' table', function() {
      $('div[data-type="modal"]').show();
      $('div[data-type=modal]').dialog('open');
    });
    return false;
  });
  
  $('a[data-role="edit_local"]').click(function() {
    $('div[data-type="modal"]').show();
    $('div[data-type="modal"]').dialog('open');
    return false;
  });
  
  if ($("form[data-tab]").size() != 0) {
    $("form:not([data-tab=filter])").hide()
  };
  
  $('a[data-role="tab"]').click(function() {
    var warpToTab = $(this).attr("data-warp");
    var currentForm = $("form[data-tab]")
    $("form").hide();
    $("form[data-tab=" + warpToTab + "]").show();
    $('div[data-type="modal"]').show();
    $('div[data-type=modal]').dialog('open');
    
    return false;
  });
  
  $('input#delivery_rejection_customer_company').autocomplete({
    source: $('input#delivery_rejection_customer_company').data("autocomplete_source")
  });
  
  $('a[data-role="edit_remote"]').click(function() {
    var remote_url = $(this).attr("href");
    $('div[data-type="modal"]').load(remote_url + ' form', function() {
      $('div[data-type="modal"]').show();
      $('div[data-type="modal"]').dialog('open');
    });
    return false;
  });
  
  $('a[data-role="edit_remote2"]').click(function() {
    var remote_url = $(this).attr("href");
    $('div[data-type="modal2"]').load(remote_url + ' form', function() {
      $('div[data-type="modal2"]').show();
      $('div[data-type="modal2"]').dialog('open');
    });
    return false;
  });
  
  $('body').on('click', 'a[data-toggle="scroll-top"]', function (e) {
    e.preventDefault();
    $("html, body").animate({ scrollTop: 0 }, "slow");
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
