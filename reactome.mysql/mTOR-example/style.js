vizmap = [

   {selector:"node", css: {
       "text-valign":"center",
       "text-halign":"center",
       "background-color": "lightgreen",
       "border-color": "black",
       "content": "data(name)",
       "border-width": "1px"
   }},

    {selector:"node[type='metabolite']", css: {
	"shape": "ellipse",
        "width": "120px;",
	"height": "80px;",
	"background-color": "lightblue"
        }},

    {selector:"node[type='reaction']", css: {
	"shape": "diamond",
        "width": "120px;",
	"height": "80px;",
	"background-color": "beige"
        }},

    {selector:"node[type='protein']", css: {
	"shape": "ellipse",
        "width": "30px;",
	"height": "30px;",
	"background-color": "beige",
	"font-size": "10px"
        }},

    {selector:"node[type='complex']", css: {
	"shape": "hexagon",
        "width": "30px;",
	"height": "30px;",
	"background-color": "beige",
	"font-size": "10px"
        }},

    {selector:"node[type='pathway']", css: {
	"shape": "round-triangle",
        "width": "60px;",
	"height": "60px;",
	"background-color": "lightblue",
	"font-size": "10px"
        }},

   {selector:"node:selected", css: {
       "text-valign":"center",
       "text-halign":"center",
       "border-color": "black",
       "font-size": "32px",
       "content": "data(id)",
       "border-width": "3px",
       "overlay-opacity": 0.5,
       "overlay-color": "blue"
       }},


   {selector: 'edge', css: {
       'line-color': 'maroon',
       'target-arrow-shape': 'triangle',
       'target-arrow-color': 'black',
       'curve-style': 'bezier'
   }},
    
   {selector: "edge[interaction='catalyzes']", css: {
       'line-color': 'gray',
       'arrow-scale': 2,
       'target-arrow-shape': 'triangle',
       'target-arrow-color': 'black',
       'line-style': "dashed",
       'curve-style': 'bezier'
   }},

   {selector: "edge[interaction='substrateOf'][reversible='true']", css: {
       'line-color': 'red',
       'source-arrow-shape': 'triangle',
       'source-arrow-color': 'black',
       'arrow-scale': 2,
       'target-arrow-shape': 'triangle',
       'target-arrow-color': 'black',
       'line-style': "solid",
       'curve-style': 'bezier'
       }},

   {selector: "edge[interaction='substrateOf'][reversible='false']", css: {
       'line-color': 'red',
       'arrow-scale': 2,
       'target-arrow-shape': 'triangle',
       'target-arrow-color': 'black',
       'line-style': "solid",
       'curve-style': 'bezier'
       }},


   {selector: "edge[interaction='produces'][reversible='true']", css: {
       'line-color': 'green',
       'arrow-scale': 2,
       'target-arrow-shape': 'triangle',
       'target-arrow-color': 'black',
       'source-arrow-shape': 'triangle',
       'source-arrow-color': 'black',
       'line-style': "solid",
       'curve-style': 'bezier'
       }},

   {selector: "edge[interaction='produces'][reversible='false']", css: {
       'line-color': 'green',
       'arrow-scale': 2,
       'target-arrow-shape': 'triangle',
       'target-arrow-color': 'black',
       'line-style': "solid",
       'curve-style': 'bezier'
       }}
    

]

