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
    'select': {
        'style': 'os',
        'selector': 'td:not(.control)'
    },
    'columnDefs':[
        {targets: [1, 5, 6], className: 'dt-left'}
    ],
    'columns': [
        {orderable: true},
        {orderable: true},
        {orderable: true},
        {orderable: true},
        {orderable: true, render: function(x){ return x=='y' ? 'yes' : x=='n' ? 'no' : '?'; }},
        {orderable: false, width: "30%"},
        {orderable: false}
    ]
});
engineTable.on('select', function(e, dt, type, indexes ) {
    if( type === 'row') {
        var engine_data = engineTable.rows(indexes).data()[0];
        console.log(engine_data);
        $.ajax({
            type: 'POST',
            url: '/engines?action=select&engine_id=' + engine_data[0],
        });
    }
});
