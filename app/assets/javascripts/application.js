// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap

/*
$(document).ready(function() {

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

  $('body').on('click.modal.data-api', '[data-toggle="modal-remote"]', function ( e ) {
    var $this = $(this);
    var href = $this.attr('href');
    var $target = $($this.attr('data-target'));
    var option = 'toggle';

    e.preventDefault();
    $target.load(href, function() {
      $target.modal(option);
    });
  });

});
*/