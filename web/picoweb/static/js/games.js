
var gameDataTable = $('#GameTable').DataTable( {
    'serverSide': true,
    'ajax': {
        'url': '/info?action=get_games_json',
	'data': function(d) {
		return JSON.stringify(d);
	}
    }
});
