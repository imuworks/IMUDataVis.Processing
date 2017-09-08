/**
 * IMU Data Visualizer for Processing.org
 *     Copyright (C) 2017 James (Aaron) Crabb
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 *  For full documentation please visit 
 *  https://github.com/jacrabb/IMUDataVis.Processing
 */

/**
 * Abstract for defining view classes with some basic parameters.
 */
abstract class view
{
  /**
   * The string name of the type of data this view displays.               */
  protected String dataName;
  /**
   * A reference to the global data store.                                 */
  protected dataWindow data;
  
  /**
   * The position in the Processing window where this view is positioned.
   * Its normal for the 'origin' of a view to be in the lower-left corner.
   * The vectorCloud's origin is intuatively in its center.                 */
  protected int xPos = 0, yPos = 0;
  /**
   * The color of the line drawn for this view.                             */
  protected color lineColor = color(128, 64, 64);  
  /**
   * Display text lables for this view true/false.                          */
  protected boolean textLabel = true;
  /**
   * Text size for any lables used in this view.                            */
  protected int textSize = 8;
  /**
   * Width of the line drawn for this view.                                 */
  protected int lineWidth = 10;
 /**
  * All values are scaled by this amount before being displayed.            */
  // TODO: should scale factor always be negative? maybe make a note to the user?
  protected float scaleFactor      = -.250F;//0.53333F; // scale value in drawing
  /**
   * Gravity factor.                                                        */
   // TODO: needs to be better documented how this is used
  protected float G                = 9.8F;  // 1 Gravity 
  
  /**
   * Must define what the view does on each draw() loop.                     */
  abstract public void paint();
  /**
   * Defines tasks this view performs on interal data on each draw() loop    */
  abstract protected void manageData();
  
  //abstract public void setScale();
  
  /**
   * Initialize the data type this view tracks.                               */
  private view(String dataTypeName, dataWindow dataref){
    dataName = dataTypeName;
    data = dataref;
    setPosition(width/2, height/2);
    setBrush();
  }
  /**
   * Initialize the data type this view tracks and position it in the window. */
  private view(String dataTypeName, dataWindow dataref, int x, int y){
    this(dataTypeName, dataref);
    setPosition(x, y);
  }
  
  /**
   * Helper method to set the Processing drawing properties to this view's.
   * Call this right before a line() or text() as things run async.
   * And remember that this does have global affect.                          */
  void setBrush()
  {
    textSize(textSize);
    strokeWeight(lineWidth);
    stroke(lineColor);
  }
  /**
   * Helper method to set the drawing properties of this view to these specified
   * and update the Processing window.
   * Call this right before a line() or text() as things run async.
   * And remember that this does have global affect.                          */
  void setBrush(int _textSize, int _lineWidth, int _r, int _g, int _b)
  {
    setTextSize(_textSize);
    setLineWidth(_lineWidth);
    setColor(_r, _g, _b);
    setBrush();
  }
  /**
   * Helper method to set the color properties of this view as specified
   * Call this right before a line() as things run async.
   * And remember that this does have global affect.                         */
  protected void setColor(color c){
    lineColor = c;
    stroke(lineColor);
  }
  /**
   * Helper method to set the color properties of this view as specified
   * Call this right before a line() as things run async.
   * And remember that this does have global affect.                         */
  protected void setColor(int _r, int _g, int _b){
    setColor(color(_r, _g, _b));
  }
  /**
   * Show or hide any text lables for this view.                             */
  protected void showLabel(boolean show){
    textLabel = show;
  }
  /**
   * Set the position within the Processing window to draw this view.
   * Conventionally, the 'origin' of a view is its lower-left corner.       */
  protected void setPosition(int x, int y){
    xPos = x; yPos = y;
  }
  /**
   * Set the width of this view's line.                                     */
  protected void setLineWidth(int w){
    lineWidth = w;
    strokeWeight(lineWidth);
  }
  /**
   * Helper method to set the text size properties of this view as specified
   * Call this right before a line() as things run async.
   * And remember that this does have global affect.                        */
  protected void setTextSize(int s){
    textSize = s;
    textSize(textSize);
  }
  
  //protected void setTextColor(int _r, int _g, int _b){
  //  tr = _r; tg = _g; tb = _b;
  //}
  
  /**
   * Set the factor whywhich values are scaled before being drawn.         */
   // TODO: why is scale factor negative.  explain in documentation
  public void setScaleFactor(float f){
    scaleFactor = f;
  }
  
}