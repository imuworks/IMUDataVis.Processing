/**
 * View to display data as a plotted line graph.
 * The graph may be either of the vector's magnitude,
 * or of any single component of the vector.
 * There is a 'peak inset' feature which will show
 * an inset graph of the most recent peak value that
 * exceeded some defined threshold.  The inset will
 * show the peak within a data window that is defined 
 * with setInsetHeight.  So, if insetHeight is set to
 * be 50, the 25 data points before and after the 
 * threshold-exceeding data point will be displayed 
 * in the inset.
 *
 * Please view the documentation at
 * https://github.com/jacrabb/IMUDataVis.Processing
 */
public class plotGraph extends view {
  /**
   * Graph the magnitude of the vector or a component.   */
  private boolean useMagnitude = true;
  /**
   * If useMagnitude is false, then this value defines
   * what vector component to display.
   * 0 = x, 1 = y, 2 = z
   * As expected for an array float[3].                 */
  private int xyz = 0; // TODO: test this
  /**
   * Show the peak inset or not.                        */
  private boolean showPeakInset = false;
  /**
   * The number of points to show in the inset.         */
  private int insetWindowSize = 50;
  /**
   * This is not well thought out.
   * This value is how many pixles horizontally is
   * drawn between points on the inset window.
   * The main graph always is 1px, but the inset
   * can be larger.  This value * insetWindowSize
   * ultimately defines the width of the inset.       */
  private int insetDotPitch = 5; // TODO: rename dotpitch
  /**
   * Horizontal position of the inset.                */
  private int xPosInset = 100;
  /**
   * Verital position of the inset.                   */
  private int yPosInset = 100;
  /**
   * TODO: is this used?                              */
  //private int height = 100;
  /**
   * Height of the inset's y axis.
   * Note that fitToHeight must be true
   * inorder for the graph height to be respected.    */
  private int insetHeight = 100; 
  /**
   * Tells the graph to scale the data to fit within
   * the defined y-axis height.
   * NOTE, fitToHeight disables scaleFactor.           */
  private boolean fitToHeight = false; // TODO: test this map() idea
  /**
   * The value to trigger the inset, if enabled.      */
  private float threshold = 13.00F;
  
  /**
   * Pointer to the value that triggered the inset.   */
  private int peakPointer = -1;
  /**
   * Data store for the inset window.                 */
  private AVector[] TempDataPoints;
  
  /**
   * Used internally to remeber last point drawn.     */
  private float PrevPointPos = 0.0F;

  /**
   * Initialize the graph to track a specified data type.
   * 
   * @param dataTypeName    stringname of data type to track         */
  public plotGraph(String dataTypeName, dataWindow dataref){
    super(dataTypeName, dataref);
  }
  /**
   * Initialize the graph to track a specified data type
   * and view position.
   * 
   * @param dataTypeName    stringname of data type to track
   * @param x               horizontal position in processing window
   * @param y               vertical position in processing window   */
  public plotGraph(String dataTypeName, dataWindow dataref, int x, int y){
    super(dataTypeName, dataref, x, y);
    xPosInset = x+xPosInset; yPosInset = y-yPosInset;
  }

  // all these functions below will automatically enable showInset
  // this causes some unnessisary reallocations of TempDataPoints
  /**
   * Display the inset graph.                                        */
  public void showInset(boolean show){
    showPeakInset = show;
    if(show) // TODO: confirm i'm not doing something terrible here be resizing the array.
      TempDataPoints = new AVector[insetWindowSize];
  }
  /**
   * Set the position of the inset graph.
   *
   * @param x               horizontal position in processing window
   * @param y               vertical position in processing window   */
  public void setInsetPos(int x, int y){
    xPosInset = x;
    yPosInset = y;
    showInset(true);
  }
  /**
   * Set the number of points to show in the inset graph.            */
  public void setInetSize(int s){
    insetWindowSize = s;
    showInset(true);
  }
  /**
   * Set the threshold value used to trigger the inset.              */
  public void setThreshold(float f){
    threshold = f;
    showInset(true);
  }
  /**
   * Graph the calculated magnitude of the vector.                   */
  public void useMagnitude(boolean use){
    useMagnitude = use;
  }
  /**
   * Graph only a specific component of the vector.
   * 0 = x, 1 = y, 2 = z
   * As expected for an array float[3].                              */
  private void component(int i){ 
    xyz = i;
    useMagnitude = false;
  }
  /**
   * Graph only the x component of the vector.                       */
  public void xComponent(){ 
    component(0);
  }
  /**
   * Graph only the y component of the vector.                       */
  public void yComponent(){
    component(1);
  }
  /**
   * Graph only the z component of the vector.                       */
  public void zComponent(){ 
    component(2);
  }
  
  /**
   * Unimplemented TODO                                              */
  private void drawBar() {
    // TODO: refactor drawing jazz to this helper funct
  }
  /**
   * Draws the view as defined. Must be called each draw() loop.     */
  public void paint(){
    manageData();
    
    int graph_l = this.data.size();
    
    if(textLabel) // TODO: how to define time period?
      text("Time (unit is undefined)",  xPos+graph_l/2,  yPos+textSize);
    stroke(255, 255, 0); // x axis
    line(xPos, yPos, xPos+graph_l, yPos);
    
    if(textLabel) 
      text(dataName,  xPos-textSize,  yPos-height);
    stroke(0, 255, 255); // y axis
    line(xPos, yPos, xPos, yPos-height);
  
  
    int position = this.data.getPointer(dataName);
    stroke(0, 128, 128);
    // this is the vertical 'painting' trace line 
    line(xPos+position-1, yPos-100, xPos+position-1, yPos);
  
    AVector[] dataWindow = this.data.getAll(dataName);
    //now madness
    for(int i = 0; i < this.data.size(); i++){
    //for (AVector v : this.data.getAll(dataName)){
      if(dataWindow[i]==null)
        break;
      
      float PointPos;
      if(useMagnitude)
        PointPos = dataWindow[i].getMag();
      else{  
        float[] d = new float[3];
         dataWindow[i].get(d);
        PointPos = d[xyz];
      }
      
      if(fitToHeight)
        PointPos = map(PointPos, -G*scaleFactor, G*scaleFactor, yPos, yPos+height);
      else
        PointPos = (PointPos * scaleFactor);
              
      setBrush();
      line(xPos+i-1, PrevPointPos+yPos, xPos+i, PointPos+yPos);
      
      PrevPointPos = PointPos;
    }
  
    if(showPeakInset) { 
      // if there's nothing in tempData, there's no 'peak' found yet and we bail.
      if(TempDataPoints == null)
          return;
          
      strokeWeight(1);
      //if(textLabel) // TODO: maybe mark the x axis somehow?
        //text("Last Peak Inset",  xPosInset+graph_l/2,  yPosInset+insetWindowSize/2);
        
      stroke(192, 192, 0); // x axis
      line(xPosInset, yPosInset, xPosInset+(insetDotPitch*insetWindowSize), yPosInset); // TODO: explain/doc windowSize * 2
      stroke(0, 192, 192); // y axis
      line(xPosInset, yPosInset, xPosInset, yPosInset-height);
    

      //now real madness
      for (int i = 0; i < insetWindowSize; i++) {
      //for (AVector v : this.data.getAll(dataName)){
        if(TempDataPoints[i]==null)
          break;
          
        float PointPos = TempDataPoints[i].getMag();
        if(fitToHeight)
          PointPos = map(PointPos, -insetHeight, insetHeight, yPos, yPos+height);
        else
          PointPos = (PointPos * scaleFactor);
                
        setBrush();
        line(xPosInset+(i-1)*insetDotPitch, PrevPointPos+yPosInset, xPosInset+i*insetDotPitch, PointPos+yPosInset);
    
        PrevPointPos = PointPos;
      }
    }
  }

  /**
   * Takes care of all the internal data that this view has.
   * In this case, that is tracking the peak inset (if enabled).         */
  void manageData(){
    if(!showPeakInset)
      return;
    //does the current mag exceed the threshhold (gforce val * threshold)
    if (this.data.getCurrent(dataName).getMag() > (G * threshold))//listMaxVec.get(listMaxVec.size()-1).mag()) 
      peakPointer = insetWindowSize/2;//this.data.getPointer(dataName)+(insetWindowSize/2); 
      // TODO: what happens when winSize not even?
    
    // when we find a peak, we set peakPointer to a position half the window size from the peak we found
    //  then when the data pointer reaches that point, we draw
    if(peakPointer == 0)
    {
      int position = this.data.getPointer(dataName)-(insetWindowSize);
      // if index is negative
      if(position < 0) // go backwards from the end that far
        position = (this.data.size() + position);
      
      // ok, so we want to capture the peak in the 'middle' of our inset 'window'
      //  so if insetWindowSize is set to 50 that means we want 25 before and 25 after.
      //  TODO: there is almost certainly a risk of an array-out-of-bounds here
      for(int i = 0; i < insetWindowSize; i++) {
        TempDataPoints[i] = this.data.get(dataName, position);
        
        if (position < this.data.size() - 1)
          position++;
        else  // word-wrap
          position = 0;
      }
    }
    
    if(peakPointer >= 0)
      peakPointer--;
  }
}