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
 * Visualizes data as a 3D vector.
 * This vector is rendered 'simply' as a
 * line in 3D space from the origin you specific
 * towards the point described by the data provided.  
 * That means orientations will not be rendered as expected.
 * For orientations, you are better off rendering a 3D object 
 * such as often done in IMU examples (adafruit bunny).
 * 
 * With limitMarks enabled it will show 'gohsts' of the vectors 
 * with the largest magnitude. With limitMarks and useThreshold 
 * enabled it will show gohsts of the most recent vectors to exceed
 * some defined threshold value.  You may define 'depth' to scale
 * the cloud in the camera's z axis.  Additionally there is a z offset
 * to move the cloud closer to the camera, which I found usefull.
 * I also found negative z values to be buggy.
 *
 * Please view the documentation at
 * https://github.com/jacrabb/IMUDataVis.Processing
 */
public class vectorCloud extends view {
  /**
   * Array of vectors found to be maximal or > threshold.   */
  private ArrayList<AVector> listMaxVec;
  /**
   * Render gohsts of maximal vectors.                      */
  private boolean limitMarks = true;
  /**
   * Draw a small origin mark.                              */
  private boolean drawOrigin = true;
  /**
   * The length of the line drawn for the origin.           */
  private int originSize = 7;
  /**
   * The number of vector gohsts to draw if limitMarks      */
  private int numberMaxVectors = 10;
  /**
   * Flip the z and y axis. 'Up' is so ambiguos these days. */
  private boolean zyFlip = false;
  /**
   * When true vector gohsts will be be triggered by 
   * exeecding a threshold.  When false, the largest
   * magnitude vectors will be draw as gohsts.              */
  private boolean useThreshold = false;
  /**
   * The threshold value to above which vector gohsts will
   * be drawn.                                              */
  private float threshold = 1.50F;
  /**
   * A scale factor for the screen's z axis when drawing
   * vectors.  Can be used to make depth more obvious.      */
  private float zScale = 5.0F;
  
  /**
   * Offset or shift the vectors in the screen's z axis.    */
  private int zShift   = 50;
  
  /**
   * Initialize the cloud to track a specified data type
   * 
   * @param dataTypeName    stringname of data type to track */
  public vectorCloud(String dataTypeName, dataWindow dataref){
    super(dataTypeName, dataref);
    scaleFactor = 1.0F;
  }
  /**
   * Initialize the cloud to track a specified data type
   * and view position.
   * 
   * @param dataTypeName    stringname of data type to track
   * @param x               horizontal position in processing window
   * @param y               vertical position in processing window   */
  public vectorCloud(String dataTypeName, dataWindow dataref, int x, int y){
    super(dataTypeName, dataref, x, y);
    scaleFactor = 1.0F;
  }
  
  /**
   * Sets the scale factor to render the raw values.   */
  public void setScale(float factor){
    scaleFactor = factor;
  } 
  /**
   * Set the depth to scale the cloud in the camera's z axis.   */
  public void setDepth(float depth){
    zScale = depth;
  }
  /**
   * Set an offset to move the cloud in the camera's z axis.   */
  public void setzOffset(int z){
    zShift = z;
  }
  /**
   * Turn on 'gohsts' of maximum or > threshold vectors.       */
  public void showMaxVectors(boolean show){
    limitMarks = show;
  }
  /**
   * Set the number of vector 'gohsts' to draw.                */
  public void setNumberMaxVectors(int n){
    numberMaxVectors = n;
  }
  /**
   * Use a threshold value to trigger vector 'gohsts'.         */
  public void useThreshold(boolean thresh){
    useThreshold = thresh;
    if(thresh)
      showMaxVectors(thresh);
  }
  /**
   * Set the threshold that triggers vector 'gohsts'.         */
  public void setThreshold(float f){
    threshold = f;
  }
  /**
   * Show the cloud's origin with x being red, y green, z blue
   * NOTE, you can't see the z axis unless the camera moves   */
  public void showOrigin(boolean show){
    drawOrigin = show;
  }
  // Lables are hard for 3D vectors because text() is not 3D
  //  this causes the tip on the vector where the text goes
  //  to not be where you expect based on the pure xy values.
  // TODO: Implement this
  /**
   * Not implemented.
   */
  @Override
  public void showLabel(boolean na){
    System.out.println("W A R N I N G/nLabels are NOT implemented for VectorClouds!!");
  }

  /**
   * Helper function called by paint() to draw lines.               */
  private void draw3D(float x, float y, float z){
    if(zyFlip){
      float t = y;
      y = z; z = t;
    }
   
    int lineComponentx = (int)(x * scaleFactor) + xPos;
    int lineComponenty = (int)(y * scaleFactor) + yPos;
    int lineComponentz = (int)((z * scaleFactor) * zScale) + zShift;
    
    line(xPos, yPos, zShift * zScale, lineComponentx, lineComponenty, lineComponentz);
  }
  /**
   * Draws the view as defined. Must be called each draw() loop.   */
  public void paint(){
    manageData();
  
    // current vector
    setBrush();
    draw3D(this.data.getCurrent(dataName).x, this.data.getCurrent(dataName).y, this.data.getCurrent(dataName).z);

    /*if(textLabel)
      text(this.data.getCurrent(dataName).getMag()/G, lineComponentx, lineComponenty);*/
    
    // max vectors
    if(limitMarks && listMaxVec != null && listMaxVec.size() > 0) {
      strokeWeight(1); stroke(255,128,128,75);
      //ArrayList<PVector> tempListMaxVec = listMaxVec;
      for (AVector v : listMaxVec)
          draw3D(v.x, v.y, v.z);
        /*if(textLabel)
          text(v.getMag()/G, v.x*scaleFactor, v.y*scaleFactor);*/
    }
    
    // 
    if(drawOrigin){
      strokeWeight(1); 
      stroke(192, 0, 0);
       line(xPos-originSize, yPos, zShift, xPos+originSize, yPos, zShift);
      stroke(0, 192, 0);
       line(xPos, yPos-originSize, zShift, xPos, yPos+originSize, zShift);
      stroke(0, 0, 192); // can't see this line unless the camera moves
       line(xPos, yPos, zShift-originSize, xPos, yPos, zShift+originSize);
    }
  }
  
  /**
   * Takes care of all the internal data that this view has.
   * In this case, that is tracking the vectors > threshold (if enabled).     */
  void manageData(){
    if(!limitMarks)
      return; // nothing to do if we aren't tracking
      
    if(listMaxVec == null || listMaxVec.size() == 0) {
      listMaxVec = new ArrayList<AVector>(); // do this here as opposed to in constructor to save memory.
      listMaxVec.add(this.data.getCurrent(dataName)); // TODO: is .copy() needed?
    }
    
    float currentMag = this.data.getCurrent(dataName).getMag();
    if(useThreshold) {
    //does the current mag exceed the threshhold (gforce val * threshold)
      // the list is sorted LIFO
      
      if (currentMag > threshold)
        listMaxVec.add(this.data.getCurrent(dataName));

       // flag ends up the last index found to be < currentMag
      
      if(listMaxVec.size() > numberMaxVectors) // only store 10 hits
        listMaxVec.remove(0); // remove the last
    } else { 
      int flag = -1;
      // the sorting of the list is enforced as we add
      
      for(AVector v : listMaxVec) {
        if (currentMag > v.getMag())
          flag = listMaxVec.indexOf(v); // flag ends up the last index found to be < currentMag
      }
      
      if(flag > -1) // found something < current and flag is now its index
        listMaxVec.add(flag+1, this.data.getCurrent(dataName)); // TODO: is copy() needed?
    }
    if(listMaxVec.size() > numberMaxVectors) // only store 10 hits
      listMaxVec.remove(0); // remove the last
  }
}