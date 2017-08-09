# IMUDataVis.Processing
Data visualization tool for IMU data captured over a serial stream in Processing.org.

This library contains several tools for graphically representing data such as that retrieved from an IMU enabled microcontroller project.  I've found, when dealing with accelerometers and gyroscopes and such, that it can be very handy to have some realtime display of the the raw data in conjunction with processed data such as filtered or compensated data.  This library is intended to provide such realtime displays in Processing for data delivered over a USB serial stream.

This library is distributed under the GNU General Public License.

To install the library, which has not been turned into a proper Processing library (partly from laziness, partly to keep the code accessible to the user for tinkering and learning), simply download or clone the git repository to where ever you keep your Processing sketches, and open the IMU_Graph.pde file which is a working example.

There are three main graph types included.
The Bar Graph
The Vector Cloud
The Plot Graph
Specific feature of each graph type are described later in the document.

For now, lets see the minimum code needed to get started with the library.

There are three main components:
The global data store.
Individual view objects.
The serial parser (which may be called statically).

The global datastore allows you to specify any number of parameters to expect coming in through your serial data stream and the order they are expected.  Each data 'type' is given a unique name which can be used to associate a view object to that specific data.  The order in which the data types are added to the global datastore also defines the order that the parser looks for the data.  The number of data points stored is set using the global data store.

Each graph you want to display is created as a view object which is associated with a data 'type' name as defined in the global datastore and is positioned in the Processing window.  There are lots of options you can set for each type of view and views can be overplayed which is useful to compare data.

Data is read from the serial stream and stored in the global data store using a serial parser.  The parser uses the order in which types were added to the data store as the order it expects data to come in via the data stream.  The parser needs each value separated by a single delimiter character and each line to begin with a special safe-line string.  By default the delimiter is a space, and the safe-line string is “||”.  That means that we expect each line of data sent from the microcontroller to look something like: || 1.0 1.1 1.2 2.0 2.1 2.2


With that overview in mind, lets walk through an example.
Our theoretical IMU project is capturing and outputting an acceleration which we would like to graph as an x/y line graph.
First we need to define our global data store object and a view object.  Place these at the top of your Processing main file before the setup() function, and after any library import statements.
[code] dataWindow alldata = new dataWindow(400);
__dataWindow__ is the data store class, and in this example we are naming it __alldata__.  The parameter sets the number of data points to store, in this case 400.  This also affects the length of the x-axis of the graph we will create.
Next let's create the view object for the graph.  
[code] plotGraph accelGraph = new barGraph("accel", alldata);
The __plotGraph__ class is used for creating an x/y line graph where the y axis is always time and the x axis is the data you are plotting.  In this case, we are naming this object __accelGraph__ as we intend to use it to plot our acceleration data, and a descriptive name such as this will help us keep things straight if we add lots more graphs.  We only need to pass two parameters to the class, that is the name of the data we expect this view to display and a reference to the global data store object.  The text string for the name of the data type needs to match exactly the string entered into the data store later.  Also while each name does need to be unique, multiple view objects can point at the same data type.
 
Finally, we need a serial object to capture and parse the data sent over from our microcontroller.
[code] SerialHndlr srl = new SerialHndlr(this, “COM9”, 115200);
Here __SerialHndlr__ is the serial handler class and we name the object __srl__.  The object needs to have the Processing applet passed which is what the keyword __this__ does.  The second parameter is the specific serial port to connect to.  In this theoretical case you are using windows and your microcontroller resisted on the Com9 port.  You will need to use the most appropriate technique to get the correct serial port for your system.  The final parameter is the boadrate which your microcontoller is using to communicate over USB.  Processing can generally handle very high baud rates, and this library is fairly optimized for speed </brag>, so you are encouraged to use the highest baudrate that is both useful and stable for your project.

Those are all the definitions that need to be done.  Next lets look at what needs to be done in the Processing setup() function.
[code] alldata.addType("accel");
This is a very important piece of code because it defines not only the types of data to be stored in the global data store, but it also defines the order in which the serial parser will look for that data.  So here we are defining only one type which we name “accel” and matches the name that our view object expects.
There are a number of options and parameters we can set for our graph, but lets only deal with the color and width of the line that is drawn.
[code] accelGraph.setColor(255, 255, 0);
  accelGraph.setLineWidth(1);
As expected, that will set the line color to an RGB value of [100%, 100%, 0%] and its width to 1 pixel (or whatever unit is defined in Processing).  You may also pass a Processing color class value to the setColor() function if that is more convienent.
For now, that's all we need to mess with, but any other parameters you would like to set for your views should be done here.
Lets say that you want to use a tab as your delimiter character because it makes it easier to read the data output in a serial console.  To set the delimiter character used by the serial parser use the code below.
[code] srl.setDelimChar('\t');
If you aren't aware, the slash you see above is a special escape character which is used to encode special characters that are hard or impossible to type.  In this case, the t indicates that we want a tab.

The next part of the Processing file is the built in draw() loop.  I recommend you set the background of the Processing window to black.
[code] background(0);

Next, make sure to call the .paint() function on all your views.  We only have setup one so far so its simple.
[code] accelGraph.paint();
This little bit of code paints the graph in the Processing window.  If we had multiple graphs, the order that these .paint() calls are made will determine the overlay order with the first calls being drawn on bottom.  This is important if you are intentionally overlaying a graph onto another to better visualize the relationship between two data types (for example if you are experimenting with different filters or similar).

The final core section of a Processing sketch is the serialEvent(Serial p) function.  Here we need to grab the serial string and pass it off to the parser.
[code] srl.parse(p.readString(), alldata);
Notice the parser also needs a reference to the global data store.

That should be it!  From here, if you start your microcontroller plugged into your computer's USB and hit the run button in Processing you should see a graph of your data (assuming your microcontroller is outputting data at the correct baudrate and with the correct string formatting)!


