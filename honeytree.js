function drawDonut(data) {
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
    // console.log(address);
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode( { 'address': address}, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            coords = results[0]['geometry']['location']['$a'] + ' ' + results[0]['geometry']['location']['ab'];
            document.getElementById("coords").value = coords;
            // alert(document.getElementById("coords").value);
            document.findTrees.submit();
        } else {
            alert("Geocode was not successful for the following reason: " + status);
        }
    });
}

function noEnter() {
  return !(window.event && window.event.keyCode == 13);
}

function drawTree(data) {
    // Create a svg canvas
    var vis = d3.select("#viz").append("svg:svg")
    .attr("width", 1000)
    .attr("height", 1000)
    .append("svg:g")
    .attr("transform", "translate(0, 40)"); // shift everything to the right

    var scaledSeparation = function(a, b) {
      return (a.parent == b.parent ? 1 : 2) / a.depth;
    };

    // Create a tree "canvas"
    var tree = d3.layout.tree()
    .size([800,800])
    .separation(scaledSeparation);

    var diagonal = d3.svg.diagonal()
    // shift it to root-at-the-bottom
    .projection(function(d) { return [d.x, (600 - d.y/1.5)]; });

    var nodes = tree.nodes(data);
    var links = tree.links(nodes);

    console.log(data);
    console.log(nodes);
    console.log(links);

    var link = vis.selectAll("path.link")
    .data(links)
    .enter()
    .append("svg:path")
    .attr("class", "link")
    .attr("d", diagonal)
    .style("stroke", "black")
    .style("fill", "none");

    var node = vis.selectAll("g.node")
    .data(nodes)
    .enter()
    .append("svg:g")
    .attr("transform", function(d) { return "translate(" + d.x + "," + (600 - d.y/1.5) + ")"; });

    var leafFill = function(d){
        return d.children == null ? "black" : "none";
    };

    // Add the dot at every node
    node.append("svg:circle")
    .attr("r", 2.5)
    .style("fill", leafFill);

    // place the name atribute left or right depending if children
    node.append("svg:text")
    .attr("dx", 3)
    // .attr("dy", -5)
    .attr("dy", function(d) { return d.children && !d.parent ? 20 : -5; })
    .attr("text-anchor", function(d) { return d.children && !d.parent ? "middle" : "start"; })
    .attr("transform", function(d) { return d.children && !d.parent ? "null" : "rotate(340)"; })
    .text(function(d) { return d.children && d.parent ? "" : d.name; });
}
