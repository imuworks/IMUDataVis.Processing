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
### Global Data Store (__dataWindow__ class)
The class __dataWindow__ is where all data retrieved from the serial stream will be stored.  The class is a wrapper for a HashMap of Strings to __AVector__ arrays which are themselves wrapped by an __imuData__ internal class.
The __AVector__ class is an extension of __PVector__ but with a precalculated magnitude to speed up rendering.  However, you will not need to worry about AVectors unless you are writing some custom feature.
By default, __dataWindow__ will store the 400 most recent data points read via serial.  This may be changed by passing an into into the constructor. 
```java
dataWindow data = new dataWindow(intHowMany);
```
The __dataWindow__ also defines the data that you expect your IMU to output over serial.  Because the underlying data is stored as a key::value pair, we can assign a unique name to each input we recieve from the IMU.  Additionally, the order inwich data is expected from the IMU is defined by the order the types are named in the __dataWindow__.  Use the method `.addType(String type)` inside the __setup()__ function to add a datatype.  The string you provide can be delimeted with commas so you may add multiple entries at once.  If a name is provided twice, either within the same comma delimeted string, or in subseqent calls to `.addType()`, the duplicate is quietly ignored.  This must be avoided as it will shift the expected ordering of your data.  For example, if you use the string "accel, gyro, accel, orientation" the second "accel" will be ignored and the order will bcome {"accel", "gyro", "orientation"}.  NOTE: There is a planed feature to help eveviate this issue.  The method `.doesTypeExist(String type)` can be used to check if a string name has already been used.
Whenever you create a view object, such as a __barGraph__ or __vectorCloud__, you will need to pass your __dataWindow__ object to that __view object__'s constructor along with the string that names the type of data the view should render.  This allows each view object to have a reference to the data store and the named dataset in it.
If you want to retrieve data from the __dataWindow__ you may use the following methods:
`.getAll(String type)` will return an array of __AVector__s which represents all the data currently stored for the named data type you requested.  Its important to note that the array is not shifted with new entries are added.  This means that the [0] position in the array is not always the oldest data.  Instead, an internal int keeps track of the current position in the array where data has most recently been added.
`.getCurrent(String type)` will return a single __AVector__ which is the most recent data added for the named data type you requested.
`.get(String type, int index)` will return a single __AVector__ at a suppied index within the internal array.  Use this function with caution, as the first position in the array does not always stored the olded value.  You may use `.getPointer(String type)` to find the array position where data was most recently added.
### Graph/Display Types
#### 2D Plot Graph (__plotGraph__ class)
Plot graph is one of the more interesting visualization tools in this library.  This tool allows you to plot a realtime 2D XY line graph of IMU data.  An example usage would be: `plotGraph accelGraph = new plotGraph("accel", data, 100, 100);`.
![alt text](https://github.com/jacrabb/IMUDataVis.Processing/raw/master/docs/plotgraph.png "IMU Data Visualizations")
The plot graph will always display all of the data stored in the __dataWindow__ and the width of the graph is always equal to the size of the __dataWindow__.  Currently, the X axis always represents time and the Y axis will be the data you requested.  By default, the view will plot the magnitude of the requested data represented as a vector.  To select a single component value you may use the methods `.xComponent()`, `.yComponent()`, `.zComponent()` respectively.  Sometimes it is not appropriate to consider the component values to be XYZ, in that case you may use `.component(intI)` and supply an integer between 0-2 that represents the array position of the data you wish to graph.  To switch back to graphing magnitudes, use `.useMagnitude(true)`.  If `.useMagnitude(false)` is called, the last component value that was set will be graphed, or by default the X component.
As with all display types, you can scale values before they are displayed using `.setScaleFactor(floatScaleFactor)`.  This will affect the height of the line being graphed.  By default, the scaleFactor is set to -0.25.  This means that data is inverted and a pixel on the screen represents 4 units of value.  If your IMU outputs data in gravity units and is set to +/-3g, you may wish to use a scalefactor something like 100 such that a measurement of 1g produces a line 100pixels tall and the graph will never be more than 600pixels high (300 above the X axis + 300 below).
Graphs can be positioned in the Processing window the same way as any other view or graph object.  You may either define the X and Y position when you call the object's constructor, or by calling `setPosition(intX, intY)`.  Remember that the origin or (0, 0) position of the window is the upper left most pixel.
You may also set the line color and thickness of plot graphs using standard methods `.setColor(intR, intG, intB)` and `.setLineWidth(intWidth)`.
Often times it is useful to plot multiple data types on the same XY graph in order to compare data.  This is easily acomplished by creating multiple __plotGraph__ objects and placing them at the same location in the Processing Window.  When doing this the order of the graphs will be determined by the order inwhich `.paint()` is called on the objects in the Processing `draw()` loop.  In the example below, each component of an accelarometer is rendered in red, green, and blue with magnitude rendered in white.
![alt text](https://github.com/jacrabb/IMUDataVis.Processing/raw/master/docs/acelplotgraph.png "IMU Data Visualizations")
In the example below, a raw accelarometer reading is visualized in a thin bright red line, with a software-low-pass-filtered version visualized in a 4px wide dark red line - Super handy!
![alt text](https://github.com/jacrabb/IMUDataVis.Processing/raw/master/docs/accelfilter2.png "IMU Data Visualizations")
The __plotGraph__ class also allows you to display an inset graph to effectively zoom-in on spikes in the data.  To enable this feature call `.showInset(true)`.  This inset is triggered by threshold value which can be set by calling `'setThreshold(floatThreshhold)`.  An example of a graph with its inset is seen below:
![alt text](https://github.com/jacrabb/IMUDataVis.Processing/raw/master/docs/inset.png "IMU Data Visualizations")
You can define the number of data points the inset will display using `.setInsetSize(intNumberofPoints)`.  As an example, if the default inset size of 50 is used when a value is detected that exceeds the threshold, the inset will be displayed showing the 25 points before and 25 after the triggering data point (if anyone can come up with a better way to say that, please let me know).  The position of this inset within the Processing window can also be set using `.setInsetPos(intX, intY)`.

#### Bar Graph (__barGraph__ class)
Bar graphs are a very simple visualization tool that simply shows your data as vertical bar graphs.
[TODO]

#### 3D Vector Cloud (__vectorCloud__ class)
[TODO]

#### 3D Frame (__frame3D__ class)
[TODO]

### Serial Parse
[TODO]


## Class Reference [TODO]
This section contains a complete reference for all classes defined in the library.
Class:
Contained in:
Properties:
Methods:



