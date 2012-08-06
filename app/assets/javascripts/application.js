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
//= require jquery-ui
//= require twitter/bootstrap
//= require_tree .

$(document).ready(function() {

  $('.date_picker').datepicker({ dateFormat: 'yy-mm-dd' });
  
  $('[data-toggle="foobar"]').click(function() {
    $.get($(this).attr("href"), function(data) {
      alert(data);
    });
    return false;
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
