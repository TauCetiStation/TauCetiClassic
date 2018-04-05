$('document').ready(function() {	
	$('#open-legend-button').click(function() {
		$('#open-legend-button').slideUp();
		$('#legend-text').slideDown();
	});
	
	$('#close-legend-button').click(function() {
		$('#open-legend-button').slideDown();
		$('#legend-text').slideUp();
	});
});