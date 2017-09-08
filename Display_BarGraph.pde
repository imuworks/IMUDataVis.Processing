/**
 * IMU Data Visualizer for Processing.org
 *     Copyright (C) 2017 James (Aaron) Crabb
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// TODO: would like to be able to display horizontal bars
// Very seriously considering making two subclasses, Mag and Components
//  but it does not seem to improve readability and does nothing 
//  for code reuse.  Maybe slightly more efficent by avoiding
//  some conditionals and not allocating the unneeded minVals for Mag. 
/**
 * View to display data as a bargraph.
 * Vectors are displayed as 3 vertical bars
 * or you may display its magnitude 
 * (using the useMagnitude() method) as single bar.
 * Optionally, you may also display 'limit marks'
 * which are small ticks to show the mose extreme
 * (positive and negative) values found.
 *
 * Please view the documentation at
 * https://github.com/jacrabb/IMUDataVis.Processing
 */
public class barGraph extends view
{
  /**
   * Graph the vector's magnitude (true) or each component (false)         */
  private boolean magnitude = false; // graph single mag vs 3 components
  
  //private int barWidth = super.lineWidth;
  
  /**
   * The height (vertical width, if you will) of limit marks.
   * Limit marks are small 'ticks' that show the most extreme values.
   * This parameter is the height of that tick mark.                       */
  private int limitMarkHeight = 3;
  
  //private int limitMarkWidth = lineWidth;
  
  /**
   * Color of limit marks.                                                 */
  private color limitMarkColor = color(255,16,16);
  /**
   * When true, limit marks will be drawn.                                 */
  private boolean limitMarks = true;
  /**
   * The space between each bar.
   * Only valid when not graphing a magnitude 
   * which is only one bar.                                                */
  private int barGap = 10;
  /**
   * Largest value detected.  Used for limit marks.                        */
  private AVector maxVals = new AVector();
  /**
   * Most negative value detected.  Used for limit marks.                  */
  private AVector minVals = new AVector();
  
  /**
   * Initialize the graph to track a specified data type.
   * 
   * @param dataTypeName    stringname of data type to track               */
  public barGraph(String dataTypeName, dataWindow dataref){
    super(dataTypeName, dataref);
  }
  /**
   * Initialize the graph to track a specified data type
   * and view position.
   * 
   * @param dataTypeName    stringname of data type to track
   * @param x               horizontal position in processing window
   * @param y               vertical position in processing window         */
  public barGraph(String dataTypeName, dataWindow dataref, int x, int y){
    super(dataTypeName, dataref, x, y);
  }
  
  /**
   * Show or hide limit marks.
   * Limit marks are 'ticks' showing the most extreme values.
   *
   * @param show            limit marks shown when true                    */
  public void showLimitMarks(boolean show){
    limitMarks = show;
  }
  /**
   * Set the limit mark color.
   * Limit marks are 'ticks' showing the most extreme values.
   *
   * @param c               limit mark color                               */
  public void setLimitMarkColor(color c){
    limitMarkColor = c;
  }
  /**
   * Set the limit mark color.
   * Limit marks are 'ticks' showing the most extreme values.
   *
   * @param _r              limit mark red color value
   * @param _g              limit mark green color value
   * @param _b              limit mark blue color value                    */
  public void setLimitMarkColor(int _r, int _g, int _b){
    setLimitMarkColor(color(_r, _g, _b));
  }
  /**
   * Set the gap between bars when rendering each vector component.
   * If useMagnitude is turned on (true) then this does nothing.
   *
   * @param p               gap between bars in pixles                     */
  public void setBarGap(int p){
    barGap = p;
  }
  /**
   * Set this to graph the magnitude of the vector.
   * If this is set to true, the graph will be a single bar,
   * otherwise it will graph each component seperately.                    */
  public void useMagnitude(boolean use){
    magnitude = use;
  }
  
  // TODO: Why is scalefactor negative? 
  /**
   * Helper function called by paint() to draw lines and text lables.     */
  private void drawBar(int barHeight, int thisxPos, String text, int max, int min){
     // this draws the line
     line(thisxPos,    yPos,    thisxPos,  barHeight + yPos);
     if(limitMarks) {
       strokeWeight(limitMarkHeight); stroke(limitMarkColor);
       int t = lineWidth/2;//limitMarkWidth/2;
       // TODO: Work on the reversing issue (notice scale factor is negative)
       if(max < 0)
         line(-t + thisxPos, max + yPos, t + thisxPos, max + yPos);
       if(min > 0)
         line(-t + thisxPos, min + yPos, t + thisxPos, min + yPos);
     }
     // add a label TODO: should be a way to scale the printed value
     
     if(textLabel){
       text(dataName, xPos-barGap-lineWidth, yPos-20);
       if(text != null)
         text(text,  thisxPos - lineWidth,  barHeight + yPos+ (barHeight < 0 ? -textSize : textSize));
     }
  }
  /**
   * Draws the view as defined. Must be called each draw() loop.     */
  public void paint(){
    manageData();
    
    int barHeight = 0, thisxPos = 0, max = 0, min = 0;
    String text = null;
    
    // If we are graphing a vector's magnitude
    if(magnitude){
     barHeight = (int)(this.data.getCurrent(dataName).getMag() * scaleFactor);
     thisxPos = xPos;
     
     text = (textLabel) ? Float.toString(this.data.getCurrent(dataName).getMag()/G) : null;
     
     if(limitMarks) {
       max = (int)(maxVals.getMag() * scaleFactor);
       // no minimum magnitude
     }
     setBrush();
     drawBar(barHeight, thisxPos, text, max, min);
    } else {
      float[] values = new float[3];
       this.data.getCurrent(dataName).get(values);
     for(int i = 0; i < 3; i++) {
       if(values == null)
         return;
       // the height of the bar is the current data point's value scaled by the scale-factor 
       barHeight = (int)(values[i] * scaleFactor);
       // the x position is the requested x pos + the # (i) of gaps + # of bars over this bar is 
       thisxPos = ((barGap + lineWidth) * i) + xPos;

       // add a label TODO: should be a way to scale the printed value (such as /9.8)
       text = textLabel ? Float.toString(values[i]/G) : null;
       
       if(limitMarks) { // maxVals.size() > 0 && minVals.size() > 0
         max = (int)(maxVals.get(new float[3])[i] * scaleFactor);
         min = (int)(minVals.get(new float[3])[i] * scaleFactor); 
//         System.out.println("Maxes["+i+"]="+max+" \t"+(maxVals.get(new float[3])[i]));
       }
       setBrush();
       drawBar(barHeight, thisxPos, text, max, min);
     }
    }
    /**/
  }
  
  // I don't like anything about this method...
  //  but is it worse than lots of .getCurrent() calls?
  /**
   * Takes care of all the internal data that this view has.
   * In this case, that is tracking the limit marks (if enabled).     */
  void manageData(){
    if(!limitMarks)
      return; // nothing to do if we aren't tracking max's
      
    float[] d = new float[3];
       this.data.getCurrent(dataName).get(d);
    float[] maxes = new float[3];
       maxVals.get(maxes);
    float[] mins = new float[3];
       minVals.get(mins);

    boolean flagMax = false, flagMin = false;
       
    for(int i = 0; i < 3; i++) {
      if(maxes[i] < d[i]){
        maxes[i] = d[i];
        flagMax = true;
      }
      
      if(mins[i] > d[i]){
        mins[i] = d[i];
        flagMin = true;
      }
    }
    if(flagMax)
      maxVals.set(maxes);
    if(flagMin)
      minVals.set(mins);
  }
}