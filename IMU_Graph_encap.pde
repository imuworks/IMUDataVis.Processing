/**
 * IMU Data Visualizer for Processing.org
 *     Copyright (C) 2017 James (Aaron) Crabb
 * 
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 * 
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 * 
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 *  For full documentation please visit 
 *  https://github.com/jacrabb/IMUDataVis.Processing
 */

import java.awt.Toolkit;
//import processing.opengl.*;

// Your serial port state passed to the SerialHandlr object
//  You may use your own serial handler and call the static parse()
SerialHndlr srl = new SerialHndlr(this, Serial.list()[0], 115200);

// Global data store
//  This must be accessible to globally and you can't rename it
// TODO: must pass ref to this obj to each class
static dataWindow alldata;

/* Define all the views you would like to have here */
/*                                                  */
barGraph accelBars, rpyBars, rpyFileredBars;

vectorCloud vectorLines, vectorNoGLines;

plotGraph accelGraph;

/** 
 * Processing setup() 
 */
void setup()
{
  // P3D enables 3D vectors
  size(1024, 600, P3D);
  frameRate(130); // generally, better using fast framerate

  // Set any parameters for the serial parse() function
  srl.setDelimChar('\t');

  // Initialize global data store
  //  The size defined here determains how many points are stored
  //  If you are not using a plotGraph, you may set size = 1
  alldata = new dataWindow(862);

  // Add all the types you wish to grab from your serial string
  //  The order defines SerialHndlr.parse()'s expectation of incoming data
  //  For example, your string format  is x y z roll pitch yaw
  //  you must addType("accel, orientation")
  // NOTICE, data in the serial string must come in consecutive triples
  //  @see SerialHndlr for more detail
  alldata.addType("orientation, complimentary");
  alldata.addType("gyroorient, gyro, accelnograv, accel");  // TODO: multiple ignore doesn't work!

  // Initialize all view objects there
  //  Pass the data type (from the definitions above) they should track
  //  Also set thier x,y position
  accelBars = new barGraph("accel", alldata, 50, 100);     // red graph - all defaults
  rpyBars = new barGraph("gyroorient", alldata, 200, 100);  // green graph
  rpyFileredBars = new barGraph("complimentary", alldata, 200, 100);  // green graph overlay

  // CAUTION, positioning a 3D vector view 
  //  at anything other than the center of the screen
  //  can result in distortion because of camera perspective
  //  If you do, also set the Z scale low
  vectorLines = new vectorCloud("accel", alldata, width/2, height/2);
  vectorNoGLines = new vectorCloud("accelnograv", alldata, width/2, 20+height/2);

  accelGraph = new plotGraph("accel", alldata, 25, 500);

  rpyBars.setColor(64, 128, 64);
  rpyBars.setLimitMarkColor(255, 255, 0);
  rpyBars.setLineWidth(20);
  //rpyBars.setScaleFactor(2.0F);

  // NOTICE, positioning a bar graph with a thin line 
  //  over a braph with a thicker line can create a good effect
  //  Set overlay.barGap=underlying.barGap+underlying.barWidth-overlay.barWidth
  //  I use this to compare raw values to filtered values
  rpyFileredBars.setColor(0, 255, 0);
  rpyFileredBars.setLineWidth(1);
  rpyFileredBars.showLabel(false);
  rpyFileredBars.showLimitMarks(false);
  rpyFileredBars.setBarGap(10+20-1); // I never added getters for these...sorry
//  rpyFileredBars.setBarGap(rpyBars.getBarGap()+rpyBars.getBarWidth()-rpyFilteredBars.getBarWidth());

  vectorLines.setColor(255, 255, 255);

  vectorNoGLines.setColor(64, 128, 64);
  vectorNoGLines.setDepth(0.125F);
  vectorNoGLines.setScale(0.125F);
  vectorNoGLines.showMaxVectors(false);

  accelGraph.setColor(255, 255, 0);
  accelGraph.setLineWidth(1);
  accelGraph.showInset(true);
}

/** 
 * Processing draw() loop
 */
void draw()
{
  // Black works best but if you change it,
  //  also change text color with fill()
  //  Views never change fill(), so its safe
  background(0);

  // This shifts display such that (0, 0) is centered in the window.
  //  You are welcome to do this and place views accordingly. 
//translate(width/2, height/2);

  /*/do this cute little thing to play with 3d lines  
   //
   int mx = mouseX;//-(width/2);
   int my = mouseY;//-(width/2);
   vectorNoGLines.setPosition(mx,my);
   text(mx+" "+my, mx, my);
   stroke(0,0,255);
   line(mx-10, my-10, 900, mx, my, 0);
   stroke(255,0,0);
   line(mx, my, 0, mx-15, my-15, 900);
   stroke(0,255,0);
   line(mx, my, 900, mx-15, my-15, -900);
  /*/

  /* call paint() on all your views here                   */
  /*  NOTICE, order matters with last being drawn 'on top' */
  accelBars.paint();
  rpyBars.paint();
  rpyFileredBars.paint();

  vectorLines.paint();
  vectorNoGLines.paint();

  accelGraph.paint();
}

/** 
 * Processing built in serial event 
 */
void serialEvent(Serial p)
{
  /* NOTICE, you can use your own serial system */
  /*  and just call the static parse() method */
  String incoming = p.readString();
//System.out.print(incoming);

  srl.parse(incoming, alldata);
//SerialHndlr.parse(incoming);
}