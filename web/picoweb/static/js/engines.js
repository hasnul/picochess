$.get('/info', {action: 'get_headers'}, function(data){
    white = '<h4>' + data.White + '</h4>';
    black = '<h4>' + data.Black + '</h4>';
    $('#current_engine').html(white + black);
    });

var engineTable = $('#EngineTable').DataTable( {
    'serverSide': true,
    'ajax': {
        'url': '/query?action=get_engines'
    },
    'columnDefs':[
        {targets: [1, 5, 6], className: 'dt-left'}
    ],
    'columns': [
        {orderable: true},
        {orderable: true},
        {orderable: true},
        {orderable: true},
        {orderable: true, render: function(x){ return x==1 ? 'yes' : 'no' }},
        {orderable: false, width: "30%"},
        {orderable: false},
        {orderable: false},
        {orderable: false}
    ]
});
