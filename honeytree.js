function create_graph(data) {
    var w = 400,
        h = 400,
        r = Math.min(w, h) / 2,
        labelr = r + 30, // radius for label anchor
        color = d3.scale.category20c(),
        donut = d3.layout.pie(),
        arc = d3.svg.arc().innerRadius(r * 0.6).outerRadius(r),
        pos = d3.svg.arc().innerRadius(r + 38).outerRadius(r + 38);

    var vis = d3.select("#chart")
        .append("svg:svg")
        .data([data])
        .attr("width", w + 300)
        .attr("height", h + 50);

    var arcs = vis.selectAll("g.arc")
        .data(donut.value(function(d) { return d.val; }))
        .enter().append("svg:g")
        .attr("class", "arc")
        .attr("transform", "translate(" + (r + 150) + "," + r + ")");

    arcs.append("svg:path")
        .attr("fill", function(d, i) { return color(i); })
        .attr("d", arc);

    arcs.append("text")
        .attr("transform", function(d) { return "translate(" + pos.centroid(d) + ")"; })
        .attr("dy", ".35em")
        .attr("text-anchor", "middle")
        .attr("display", function(d) { return d.value > 3.0 ? null : "none"; })
        .text(function(d, i) { 
            return d.data.name;
        });
}

function inputFocus(i){
    if(i.value=="enter your hive's NYC street address"){ i.value="";}
}

function geocodeAndSubmit(){
    var address = document.getElementById("address").value;
    console.log(address);
    console.log("hi!");
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode( { 'address': address}, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            coords = results[0]['geometry']['location']['$a'] + ' ' + results[0]['geometry']['location']['ab'];
            document.getElementById("address").value = coords;
            alert(coords);
            document.findTrees.submit();
        } else {
            alert("Geocode was not successful for the following reason: " + status);
        }
    });
}

function noEnter() {
  return !(window.event && window.event.keyCode == 13); 
}