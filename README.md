# IMUDataVis.Processing
## Intro
This library contains several tools for graphically representing data such as that retrieved from an IMU enabled microcontroller project.  I've found, when dealing with accelerometers and gyroscopes and such, that it can be very handy to have some realtime display of the the raw data in conjunction with processed data such as filtered or compensated data.  This library is intended to provide such realtime displays in Processing for data delivered over a USB serial stream.

![alt text](https://github.com/jacrabb/IMUDataVis.Processing/raw/master/docs/screen1.png "IMU Data Visualizations")

This library is distributed under the GNU General Public License.
## Overview
### Installing
To install the library, which has not been turned into a compiled Processing Java library, simply download or clone this git repository to where ever you keep your Processing sketches, and open the __IMU_Graph.pde__ file which is a working example.  You should see a screen similar to what is below:
![alt text](https://raw.githubusercontent.com/jacrabb/IMUDataVis.Processing/master/docs/just_opened.gif "Processing window after opening the IMU Visualizer")
### Graph Types
There are three main graph types included.

- The Bar Graph
![alt text](https://github.com/jacrabb/IMUDataVis.Processing/docs/bargraph.png "A barGraph object")
`barGraph yprBars = new barGraph("orientation", alldata, 50, 100);`
- The Vector Cloud
![alt text](https://github.com/jacrabb/IMUDataVis.Processing/docs/vcloud.png "A vectorCloud object")
`vectorCloud accelVectors = new vectorCloud("accel", alldata, width/2, height/2);`
- The Plot Graph
![alt text](https://github.com/jacrabb/IMUDataVis.Processing/docs/plotgraph .png "A plotGraph object")
`plotGraph gyroplot = new plotGraph("gyro", alldata, 25, 500);`

Specific feature of each graph type are described later in the document.
### Setting Up
For now, lets see the minimum code needed to get started with the library.

There are three main components:

- The __global datastore__.
- Individual __view objects__.
- The __serial parser__ (which may be called statically).

The __global datastore__ allows you to specify any number of parameters to expect coming in through your serial data stream and the order they are expected.  Each data 'type' is given a unique name which can be used to associate a __view object__ to that specific data.  The order in which the data types are added to the __global datastore__ also defines the order that the parser looks for the data in the serial stream.  The number of data points stored is set using the __global datastore__.

Each graph you want to display is created as a __view object__ which is associated with a data 'type' name as defined in the __global datastore__ and is positioned in the Processing window.  There are lots of options you can set for each type of view and views can be overlayed which is useful to compare data.

Data is read from the serial stream and stored in the __global datastore__ using a __serial parser__.  The parser uses the order in which types were added to the data store as the order it expects data to come in via the data stream.  The parser needs each value separated by a single delimiter character and each line to begin with a special safe-line string.  By default the delimiter is a space, and the safe-line string is “||”.  That means that we expect each line of data sent from the microcontroller to look something like: `|| 1.0 1.1 1.2 2.0 2.1 2.2`
### Simple Walkthrough
With that overview in mind, lets walk through an example.
Our theoretical IMU project is capturing and outputting an acceleration which we would like to graph as an x/y line graph.
First we need to define our __global data store__ object and a __view object__.  Place these definitions in your Processing main file inside the `setup()` function, and after any library import statements.
`dataWindow alldata = new dataWindow(400);`
`dataWindow` is the data store class, and in this example we are naming it `alldata`.  The parameter sets the number of data points to store, in this case 400.  This also affects the length of the x-axis of the graph we will create, as the graph will plot all the data being stored.
Next let's create the __view object__ for the graph.   
`plotGraph accelGraph = new barGraph("accel", alldata);`
The __plotGraph__ class is used for creating an x/y line graph where the y axis is always time and the x axis is the data you are plotting.  In this case, we are naming this object __accelGraph__ as we intend to use it to plot our acceleration data, and a descriptive name such as this will help us keep things straight if we add lots more graphs.  We only need to pass two parameters to the class, that is the name of the data we expect this view to display and a reference to the __global data store__ object.  The text string for the name of the data type needs to match exactly the string entered into the data store later.  Also while each name does need to be unique, multiple __view objects__ can point at the same data type.
 
Finally, we need a __serial object__ to capture and parse the data sent over from our microcontroller.
`SerialHndlr srl = new SerialHndlr(this, “COM9”, 115200);`
Here `SerialHndlr` is the serial handler class and we name the object `srl`.  The object needs to have the Processing applet passed which is what the keyword `this` does.  The second parameter is the specific serial port to connect to.  In this theoretical case you are using windows and your microcontroller resides on the Com9 port.  You will need to use the most appropriate technique to get the correct serial port for your system.  The final parameter is the boadrate which your microcontoller is using to communicate over USB.  Processing can generally handle very high baud rates, and this library is fairly optimized for speed *#endbrag*, so you are encouraged to use the highest baudrate that is both useful and stable for your project.

At this point you should have the following:
```java
dataWindow alldata = new dataWindow(400);
plotGraph accelGraph = new barGraph("accel", alldata);
SerialHndlr srl = new SerialHndlr(this, “COM9”, 115200);
```

With are all the done, next lets look at what needs to be done in the Processing __setup()__ function.
One bit of housekeeping to do here is set the size of the processing window.  Its rather small by default and we want to have a good bit of space to view our data. 
`size(1024, 600, P3D);`
The last argument `P3D` is needed to use the `vectorCloud` graph.
Now we can do the fun stuff, such as define the data types we expect in our serial stream.  Right now we only have an acceleration value which we are graphing, but lets assume that our microcontroller is also outputting a gyro value.  If the output format is gyro first, then accel, we would use the code below.
`alldata.addType("gyro, accel");`
This is a very important piece of code because it defines not only the types of data to be stored in the global data store, but it also defines the order in which the __serial parser__ will look for that data.  So here we are defining only one type which we name “accel” and matches the name that our __view object__ expects.
There are a number of options and parameters we can set for our graph, but lets only deal with the color and width of the line that is drawn.
`accelGraph.setColor(255, 255, 0);`
`accelGraph.setLineWidth(1);`
As expected, this will set the line color to an RGB value of [100%, 100%, 0%] and its width to 1 pixel (or whatever unit is defined in Processing).  You may also pass a Processing color class value to the `.setColor()` function if that is more convenient.

Lets say that you want to use a tab as your delimiter character in the serial stream because it makes it easier to read the data output in a serial console.  To set the delimiter character used by the serial parser use the code below.
`srl.setDelimChar('\t');`
If you aren't aware, the slash you see above is a special escape character which is used to encode special characters that are hard or impossible to type.  In this case, the t indicates that we want a tab.
That should do it.  Your code should now look like the following:
```java
void setup(){
	size(1024, 600, P3D);
	alldata.addType("gyro, accel");
	accelGraph.setColor(255, 255, 0);
	accelGraph.setLineWidth(1);
	srl.setDelimChar('\t');
}
```

The next part of the Processing file is the built in `draw()` loop.  I recommend you set the background of the Processing window to black.
`background(0);`
Next, make sure to call the `.paint()` function on all your views.  We only have setup one so far so its simple.
`accelGraph.paint();`
This little bit of code paints the graph in the Processing window.  If we had multiple graphs, the order that these __.paint()__ calls are made will determine the overlay order with the first calls being drawn on bottom.  This is important if you are intentionally overlaying a graph onto another to better visualize the relationship between two data types (for example if you are experimenting with different filters or similar).
```java
void draw(){
	background(0);
	accelGraph.paint();
}
```

The final core section of a Processing sketch is the `serialEvent(Serial p)` function.  Here we just need to grab the serial string and pass it off to the parser.
`srl.parse(p.readString(), alldata);`
Notice the parser also needs a reference to the global data store.  That should be it!
##### Working Code
```java
dataWindow alldata = new dataWindow(400);
plotGraph accelGraph = new barGraph("accel", alldata);
SerialHndlr srl = new SerialHndlr(this, “COM9”, 115200);

void setup(){
	size(1024, 600, P3D);
	alldata.addType("gyro, accel");
	accelGraph.setColor(255, 255, 0);
	accelGraph.setLineWidth(1);
	srl.setDelimChar('\t');
}

void draw(){
	background(0);
	accelGraph.paint();
}

void serialEvent(Serial p)
{
	srl.parse(p.readString(), alldata);
}
```

From here, if you start your microcontroller plugged into your computer's USB and hit the run button in Processing you should see a graph of your data (assuming your microcontroller is outputting data at the correct baudrate and with the correct string formatting)!

## Advanced Features
### data store
### graph types
#### plot graph
#### bar graph
#### vector cloud
### serial parse


## Class Reference
This section contains a complete reference for all classes defined in the library.
Class:
Contained in:
Properties:
Methods:



