$(document).ready(function(){


	$(document).on('click','#hit_form input',function() {

		$.ajax({
			type: 'POST',
			url: '/game/hit'
		}).done(function(msg) {
			$('#Game').replaceWith(msg);
		});

		return false;
	});

	$(document).on('click','#stay_form input',function() {

		$.ajax({
			type: 'POST',
			url: '/game/stay'
		}).done(function(msg) {
			$('#Game').replaceWith(msg);
		});

		return false;
	});

	$(document).on('click','#Start_Over_form input',function() {

		$.ajax({
			type: 'GET',
			url: '/bet'
		}).done(function(msg) {
			$('#Game').replaceWith(msg);
		});

		return false;
	});

});