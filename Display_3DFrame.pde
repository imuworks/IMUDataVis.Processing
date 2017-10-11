/**
 * IMU Data Visualizer for Processing.org
 *     Copyright (C) 2017 James (Aaron) Crabb
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
/**
 * View to display a 3D orientation.
 * This class renders a 3D object given an orientation from the IMU.
 * Optinaly, you can use this as a ref frame for various effects.
 *
 * Please view the documentation at
 * https://github.com/jacrabb/IMUDataVis.Processing
 */
public class frame3D extends view
{
  /**
   * Expect degree (true) or radian (false) values                         */
  private boolean degrees = false;
  
  /**
   * Diameter of the 3D object (regardless of type)                        */
  private int diameter = 100;
  
  /**
   * Color of trace gohsts.                                                */
  private color traceColor = color(255,255,255,50);
  /**
   * When true, trace gohsts will be drawn.                                */
  private boolean traceMarks = true;
  /**
   * Number of samples to let trace gohsts last.                           */
  private int traceAge = 100;

  /**
   * Initialize the graph to track a specified data type.
   * 
   * @param dataTypeName    stringname of data type to track               */
  public frame3D(String dataTypeName, dataWindow dataref){
    super(dataTypeName, dataref);
  }
  /**
   * Initialize the graph to track a specified data type
   * and view position.
   * 
   * @param dataTypeName    stringname of data type to track
   * @param x               horizontal position in processing window
   * @param y               vertical position in processing window         */
  public frame3D(String dataTypeName, dataWindow dataref, int x, int y){
    super(dataTypeName, dataref, x, y);
  }
  
  /**
   * Show or hide limit marks.
   * Limit marks are 'ticks' showing the most extreme values.
   *
   * @param show            limit marks shown when true                    */
  public void showTraceMarks(boolean show){
    traceMarks = show;
  }
  /**
   * Set the limit mark color.
   * Limit marks are 'ticks' showing the most extreme values.
   *
   * @param c               limit mark color                               */
  public void setTraceMarksColor(color c){
    traceColor = c;
  }
  /**
   * Set the limit mark color.
   * Limit marks are 'ticks' showing the most extreme values.
   *
   * @param _r              limit mark red color value
   * @param _g              limit mark green color value
   * @param _b              limit mark blue color value                    */
  public void setTraceMarksColor(int _r, int _g, int _b){
    setTraceMarksColor(color(_r, _g, _b));
  }

  /**
   * Set graph to use degrees.                                             */
  public void useDegrees(boolean use){
    degrees = true;
  }
  /**
   * Set graph to use degrees.                                             */
  public void useRads(boolean use){
    degrees = false;
  }
  
  // TODO: Why is scalefactor negative? 
  /**
   * Helper function called by paint() to draw lines and text lables.     */
  private void draw3D(float roll, float pitch, float yaw){
    int radius = diameter/2;
    {pushMatrix();
     // center object but add the x/y position
     translate((width / 2)+xPos, (height / 2)+yPos);
     //rotate
     rotateX(roll);
     rotateY(pitch);
     rotateZ(yaw);
     // X red
     {pushMatrix(); translate(radius,0,0);
     fill(255, 0, 0, 200);     box(diameter, 10, 10);     popMatrix();}
     // Y green
     {pushMatrix(); translate(0,radius,0);
     fill(0, 255, 0, 200);     box(10, diameter, 10);     popMatrix();}
     // Z blue
     {pushMatrix(); translate(0,0,radius);
     fill(0, 0, 255, 200);     box(10, 10, diameter);     popMatrix();}
     {pushMatrix();
      translate(0, 0, -120);
      rotateX(PI/2);
      //drawCylinder(0, 20, 20, 8);
     popMatrix();}
    popMatrix();}

     
     if(textLabel){
       //text(dataName, xPos-barGap-lineWidth, yPos-20);
       //if(text != null)
       //  text(text,  thisxPos - lineWidth,  barHeight + yPos+ (barHeight < 0 ? -textSize : textSize));
     }
  }
  /**
   * Draws the view as defined. Must be called each draw() loop.     */
  public void paint(){
    manageData();
    draw3D(alldata.getCurrent(dataName).x, alldata.getCurrent(dataName).y, alldata.getCurrent(dataName).z);
    /*
    if(traceMarks){
      if(traceAge > alldata.size()-1)
        traceAge = alldata.size()-1;
    for (int i = 0; i < traceAge; i--)
    {
      //
    }
    }*/
  }
 
  /**
   * Takes care of all the internal data that this view has.
   * In this case, that is tracking the limit marks (if enabled).     */
  void manageData(){
    
  }
}