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
    .projection(function(d) { return [(100 + d.x), (730 - d.y/1.5)]; });

    var nodes = tree.nodes(data);
    var links = tree.links(nodes);

    // Create the tree branches as those nice curved black lines
    var link = vis.selectAll("path.link")
    .data(links)
    .enter()
    .append("svg:path")
    .attr("class", "link")
    .attr("d", diagonal)
    .style("stroke", "#633A11")
    .style("stroke-width", 3)
    .style("fill", "none");

    var node = vis.selectAll("g.node")
    .data(nodes)
    .enter()
    .append("svg:g")
    .attr("transform", function(d) { return "translate(" + (100 + d.x) + "," + (730 - d.y/1.5) + ")"; });

    var leafFill = function(d){
        return d.children == null ? "green" : "none";
    };

    function leafPath(x,y) {
        // Created the path in Adobe Illustrator by sketching with my tablet
        return "M42.125,85.543c-2.827-5.804-11.756-10.715-18.899-12.798" +
            "S-0.286,62.18,14,52.358s25.446-1.042,23.81-8.036c-1.637-6.994-12.054-5.357-8.929-11.905s8.482-2.083,14.583-9.672" +
            "S52.096,3.4,55.815,10.692s0.594,15.773,6.547,18.006s24.703,5.06,12.203,12.649s-25.298,9.821-13.244,16.071" +
            "s33.482,11.16,5.506,20.685s-26.191,4.614-25.298,10.715c0.592,4.045,9.219-65.417,9.971-66.37c2.231-2.827-6.422,20.834-1.5,20.387" +
            "s17.721-5.952,20.25-5.06S51.328,41.644,50,44.918c-1.328,3.274-8.173-9.822-13.232-9.97s21.131,8.184,6.845,29.464" +
            "s-10.565-12.203-25.595-4.167s60.416,7.143,53.72,8.929";
    }

    function rotateLeaves(d){
        if (!d.percent) {
            return "null";
        } else if (d.parent && d.parent.children[0].name == d.name) {
            return "scale(" + (0.1 * d.percent) + ")" + "rotate(-35)" + "translate(-42.125,-85.543)";
        } else {
            return "scale(" + (0.1 * d.percent) + ")" + "rotate(15)" + "translate(-42.125,-85.543)";
        }
    }

    function transformText(d){
        if (!d.parent) {
            return "null";
        } else if (d.parent && d.parent.children[0].name == d.name) {
            return "translate(-5,-15) rotate(270)";
        } else {
            return "translate(15,-15) rotate(270)";
        }
    }

    node.append("svg:path")
    .attr("d", function() { return leafPath(d.x, d.y); })
    .attr("transform", rotateLeaves)
    .style("fill-opacity", 0.7)
    .style("fill", leafFill);

    // place the name atribute angled and right if leaf, centered and horizontal if root
    node.append("svg:text")
    .attr("dx", -3)
    // .attr("dy", -5)
    .attr("dy", function(d) { return d.children && !d.parent ? 20 : 1; })
    .attr("text-anchor", function(d) { return d.children && !d.parent ? "middle" : "start"; })
    .attr("transform", transformText)
    .text(function(d) { return d.children && d.parent ? "" : d.name; })
    .style("font-size", "18px");
}
