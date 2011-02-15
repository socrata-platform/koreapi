;var metricsNS = {}; 

metricsNS.getSeries = function(m, data)
{
    var startDate = data[0]['start'];
    var pointInterval = data[0]['end'] - data[0]['start'] + 1;
    var seriesDefaults = {
            id: m,
            lineWidth: 4,
            pointInterval: pointInterval,
            pointStart: startDate
        };

    // Fill in any holes not returned by balboa
    var ungappedData = [];
    var intervalEnd = 0;

    $.each(data, function(j, row)
    {
        if (intervalEnd > 0 &&
            (row['start'] - intervalEnd) > 1)
        {
            for (var j = 0; j < ((row['start'] - intervalEnd) / pointInterval) - 1; j++)
            { 
                ungappedData.push(0); 
            }
        }
        intervalEnd = row['end'];
        var slice = (row.metrics || {});
        var metric = (slice || {})[m];
        var value = (metric || {value: 0}).value;

        ungappedData.push(value);
    });

    var plot = $.extend({}, seriesDefaults, {
        data: ungappedData
    });

    plot.name = m; 

    return plot;
};

/*
 * This takes series data returned from the metrics service
 * and turns it into a properly styled time series area chart
 * @param series: a comma-separated list of series to plot
 */

metricsNS.renderMetricsChart = function(data, $chart, sliceType, series, options)
{
    if (data.length < 1)
    { return; }

    // Get the date from which the data actually starts and setup some
    // chart configuration options.
    var pointInterval = data[0]['end'] - data[0]['start'] + 1,
        seriesToPlot = [],
        showLabels = true;

    // Make highchart series object for each item
    for (var i=0; i < series.length; i++)
    {
        seriesToPlot.push(metricsNS.getSeries(series[i], data));
    }

    // Kill off an existing chart if re-drawing to avoid leaks
    if ($chart.data('highchart') != null)
    { $chart.data('highchart').destroy(); }

    $chart.show();

    // Attributes specific to this chart
    var chartAttributes = $.extend(true, {}, metricsNS.chartDefaults, {
        chart: {
            renderTo: $chart.attr('id')
        },
        xAxis: {
            maxZoom: pointInterval
        },
        series: seriesToPlot,
        tooltip: {
            formatter: function() {
                return '' + Highcharts.dateFormat(metricsNS.tooltipFormats[sliceType],
                    this.x) + ': ' + Highcharts.numberFormat(this.y, 0);
            }
        }
    });

    // Keep track of the chart object to properly destroy it on refresh
    $chart
        .data('highchart',
            new Highcharts.Chart($.extend(true, chartAttributes, options || {})));
};

// How to format the tooltips, based on how deep they slice
metricsNS.tooltipFormats = {
    'HOURLY': '%A %B %e %Y %H:%M',
    'DAILY': '%A %B %e %Y',
    'WEEKLY': '%B %e %Y',
    'MONTHLY': '%B %Y',
    'YEARLY': '%Y'
};


metricsNS.chartDefaults = {
    chart: {
        defaultSeriesType: 'line',
        height: 300,
        margin: [20, 0, 30, 0],
        zoomType: 'x'
    },
    plotOptions: {
        spline: { marker: {enabled: false}}
    },
    credits: {
        enabled: false
    },
    title: {
        text: null
    },
    navigation: {
        menuStyle: {
            'float': 'right'
        }
    },
    xAxis: {
        type: 'datetime',
        title: {
            text: null
        },
        tickPosition:  'inside',
        showLastLabel:  false,
        minPadding: 0.01,
        maxPadding: 0.01,
        dateTimeLabelFormats: {
            second: '%H:%M:%S',
            minute: '%H:%M',
            hour: '%b %e %H:%M',
            week: '%b %e',
            month: '%b \'%y',
            day: '%b %e'
        },
        labels: {
            align: 'left',
            x: 2,
            y: 12
        }
    },
    yAxis: {
        title: {
            text: null
        },
        tickPosition: 'inside',
        showFirstLabel: false,
        labels: {
            align: 'left',
            formatter: function() {
                return Highcharts.numberFormat(this.value, 0);
            },
            y: -2,
            x: 2
        }
    },
    colors: [
        '#bee6f6',
        '#ee3c39'
    ],
    legend: {
        backgroundColor: '#fff',
        enabled: true,
        align: 'right',
        verticalAlign: 'top',
        y: 5,
        x: 0
    }
};

