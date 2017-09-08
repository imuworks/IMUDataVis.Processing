/**
 * IMU Data Visualizer for Processing.org
 *     Copyright (C) 2017 James (Aaron) Crabb
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 *  For full documentation please visit 
 *  https://github.com/jacrabb/IMUDataVis.Processing
 */
 
//import java.util.Iterator;
import java.util.Arrays;
import java.util.LinkedHashMap;
//import java.util.List;

/**
 * Where all data retrieved from the serial stream will be stored.
 * This class is a wrapper for a HashMap of PVector primitive arrays
 * which are themselves wrapped by the imuData internal class.
 */
public class dataWindow {
  /** 
   * Underlying data length.                            */
  private int Length = 400; 

  /**
   * Underlying data structure.                         */
  public LinkedHashMap<String, imuData> DataPoints; // TODO: should not be public
  
  /**
   * Initialize with default length.                    */
  public dataWindow(){
    DataPoints = new LinkedHashMap<String, imuData>(Length);
  }
  /**
   * Initialize with specified length.
   * 
   * @param HowMany the length of the underlying array
   *                which defines how many data points
   *                to store                            */
  public dataWindow(int HowMany){
    Length = HowMany;
    //this();  // hate that you can't do this
    DataPoints = new LinkedHashMap<String, imuData>(Length);
  }
  
  /**
   * Adds to the end of a specified named type's array.
   * 
   * @param type  the named type (key) to add to
   * @param d     the data vector to add                */
  public void addPoint(String type, AVector d){
    if(doesTypeExist(type))
      DataPoints.get(type).put(d);
  }
  /**
   * Adds to the end of a specified named type's array.
   * 
   * @param type  the named type (key) to add to
   * @param d     the data vector to add represented
   *              as a float array of len 3             */
  public void addPoint(String type, float[] d){
    if(doesTypeExist(type))
      addPoint(type, new AVector().set(d));
  }
  /**
   * Adds to the end of a specified named type's array.
   * 
   * @param type  the named type (key) to add to
   * @param x     the x component of the vector to add
   * @param y     the y component of the vector to add
   * @param z     the z component of the vector to add  */
  public void addPoint(String type, float x, float y, float z){
    if(doesTypeExist(type))
      addPoint(type, new AVector(x, y, z));
  }

  /**
   * Finds out if a type is being tracked in the data store.
   * 
   * @return      true if the key exists
   *
   * @param type  string type name to look up          */
  public boolean doesTypeExist(String type){
    return DataPoints.containsKey(type);
  }
  
  /**
   * Adds a type for the data store to track.
   *
   * @param type  string type name to add             */
  public void addType(String type){
    String[] list = split(type, ',');
    if (list.length > 0) {
      for(String s : list) {
        String trimType = trim(s);
        if(!doesTypeExist(trimType))
          DataPoints.put(trimType, new imuData(Length));
        //if(trimType != "ignore" && trimType != "null")  // these keys act as placeholders
        addPoint(trimType, new AVector(0, 0, 0)); // init to zero for simplicity (no reason not to)
      }
    }
  }
  
  //TODO: keySet() returns a set, 
  //       need to convert to ArrayList
  //       or use iterable<>
  //public ArrayList<String> getTypeList(){
  //  return DataPoints.keySet();
  //}
  
  /**
   * Gets all the stored data points of a specific type.
   * 
   * @return      an array of vectors of len this.Length or
   *              if type not found a vector 404 is returned
   *              if null error occurs vector 500 is returned 
   * 
   * @param type  string type name who's data to get
   */
   // TODO: make an iterator<> version
  public /*Iterator<AVector>*/ AVector[] getAll(String type)
  {
    if(!doesTypeExist(type))
      return new AVector[] {new AVector(4, 0, 4)};
      
    AVector[] temp = DataPoints.get(type).getWindow();

    if(temp[0] == null)
     return new AVector[] {new AVector(5, 0, 0)};

    return temp;//.iterator();
   
  }

  /**
   * Gets a stored data point of a specific type at a specified index.
   *
   * @return      the requested vector if found or
   *              if type not found a vector 404 is returned
   *              if null error occurs vector 500 is returned 
   *
   * @param type  string type name who's data to get
   * @param index the array index to get data from
   */
  // TODO: Custom errors and warnings (not this hack)
  public AVector get(String type, int index){
    if(!doesTypeExist(type))
      return new AVector(4, 0, 4); // 404 not found, see...its funny
      
    AVector temp = DataPoints.get(type).getIndex(index);
    
    if(temp == null)
     return new AVector(5, 0, 0);

    return temp;
  }

  /**
   * Gets the most recent data point that has been added for a specific type.
   *
   * @return      the requested vector if found or
   *              if type not found a vector 404 is returned
   *              if null error occurs vector 500 is returned 
   *
   * @param type  string type name who's data to get
   */
  public AVector getCurrent(String type){
    if(!doesTypeExist(type))
      return new AVector(4, 0, 4);
      
    AVector temp = DataPoints.get(type).getCurrent();
    
    if(temp == null)
     return new AVector(5, 0, 0);

    return temp;
  }

  /**
   * Gets the index of the most recent data added for a specific type.
   *
   * @return      the index of most recent data point
   * 
   * @param type  string type name who's current index to get
   */
  public int getPointer(String type){
    return(DataPoints.get(type).Pointer);
  }

  /**
   * The length of the underlying data array.  This is the total
   * number of data points that can be recorded or displayed. 
   * This also will be the width (x-axis) of any plotGraph objects.
   * This length should be the same for all stored data types.
   *
   * @return      the data array length
   *              total number of data points that can bestored
   */
  public int size(){
    return Length;
  }
  
  /**
   * Unimplemented function to make sure all data types are synced up.
   * That is to say that each wuld return the same getPointer() index.
   * There's no way to get out of sync given the current implementation.
   */
  // TODO: Is this ever needed?
  /*public boolean synced(){
    int f = 0;
    int count = 0;
    boolean status = true;
    for (String type : DataPoints.keySet())
    {
      if(count == 0)
        f = getPointer(type);
      else
        status = f == getPointer(type);
      count ++;
    }
    return status;
  }*/


  /**
   * Underlying data class that exposes a primitive array of vectors.
   * 
   */
  // TODO: extend iterable?
  private class imuData {
    /**
     * Underlying data.     */
    private AVector[] data;
    /**
     * Index of most recent data added.     */
    public int Pointer = -1;
    /**
     * The length of the data array.     */
    private int Length;
    /**
     * Unimplemented flag to switch between two modes     */
    private boolean wordwrap = true;
    
    /**
     * Initialize underlying data array with specified length.
     * 
     * @param l   the length to initialize the array to     */
    public imuData(int l){
     Length = l;
     data = new AVector[l];
    }
    
    /**
     * Puts a vector into the underlying array at the 'current' position.
     * The 'current' position is stored in pointer and wraps to 0 at end of array 
     * 
     * @param v     the vector to insert into the data array     */
    // is there a way to also make a way to scroll (as opposed to word wrap)?
    //  using an ArrayList might well do it.  
    //  I went with a primitive array for performance reasons, but with the
    //  limitation of having to 'word-wrap'.  A List would stay ordered, but
    //  require that the oldest be deleted (if over Length).
    //  A linked list is ideal fr the non-word-wrap version.
    public void put(AVector v){
      // this handles the 'word-wrap' of the array
      if (Pointer < Length - 1)
        Pointer++;
      else  // word-wrap
        Pointer = 0;
        
      data[Pointer] = v;
      //System.out.println("Adding " + v + " at " + Pointer + " to " + data[Pointer]);
    }
    
    /**
     * Gets the most recently added data from the underlying array.
     * 
     * @return      the most recent vector added     */
    public AVector getCurrent(){
      return data[Pointer];
    }

    /**
     * Gets the data stored at a specific index. Does not check for null.
     * 
     * @return      the vector stored at the specified array index
     *
     * @param i     the array index to get data from     */
    public AVector getIndex(int i){
      return data[max(min(i, Length - 1), 0)];
    }
    
    /**
     * Unimplementd iterable version of getWindow     */
    //public List<AVector> getWindow()

    /**
     * Get the stored data.     */
    public AVector[] getWindow()
    {
      // the asList function is nice because the List is iterable
      //  and there is no data copy. 
      if (wordwrap)
        return data;// Arrays.asList(data); // TODO: an alternative is ArrayList
      else{
        // TODO ? For a scrolling list we want a linked-list kind of structure.
        //       Should give performant removal of the oldest element.
        //  --or we keep primitive array but sacrifice performance to reconstruct for scrolling  
        return data;// Arrays.asList(data);
        //return java.util.LinkedList.toArray(data); 
      }
    }
    
    /**
     * Get the size of the underlying data array.
     * This is the maximum number of data points that can be stored.
     *
     * @return      the size of the underlying array     */
    public int size(){
      return Length;
    }
  }


}