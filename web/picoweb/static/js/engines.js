$.get('/info', {action: 'get_system_info'}, function(data){
    engine = '<h4>Name: ' + data.engine_name + '</h4>';
    level = '<h4>Level: ' + data.level + '</h4>';
    $('#current_engine').html(engine + level);
    console.log(data);
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
