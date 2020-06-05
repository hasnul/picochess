
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
