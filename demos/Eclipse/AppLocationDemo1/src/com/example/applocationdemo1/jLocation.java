package com.example.applocationdemo1;

import java.io.IOException;
import java.util.List;
import java.util.Locale;

import android.content.Context;
import android.content.Intent;
import android.location.Address;
import android.location.Criteria;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.location.LocationProvider;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.provider.Settings;

/*Draft java code by "Lazarus Android Module Wizard" [8/9/2014 20:25:55]*/
/*https://github.com/jmpessoa/lazandroidmodulewizard*/
/*jControl template*/

//ref. 1:  http://examples.javacodegeeks.com/android/core/location/android-location-based-services-example/
//ref. 2   http://examples.javacodegeeks.com/android/core/location/proximity-alerts-example/
//ref. 3:  http://www.wingnity.com/blog/android-gps-location-address-using-location-manager/
//ref. 4:  http://www.techrepublic.com/blog/software-engineer/take-advantage-of-androids-gps-api/
//ref. 5:  http://androidexample.com/GPS_Basic__-__Android_Example/index.php?view=article_discription&aid=68&aaid=93
//ref. 6:  http://hejp.co.uk/android/android-gps-example/
//ref. 7:  http://www.slideshare.net/androidstream/android-gps-tutorial

public class jLocation /*extends ...*/ {

    private long     pascalObj = 0;      // Pascal Object
    private Controls controls  = null;   // Control Class -> Java/Pascal Interface ...
    private Context  context   = null;

    private MyLocationListener mlistener;    
    private LocationManager mLocationManager;
    private Criteria mCriteria;
    private String mProvider;
    private String mLatitude;
    private String mLongitude;
    private String mAltitude;
        
    private String mAddress;
    private String mStatus;
    
    //The minimum distance to change Updates in meters
    private long mDistanceForUpdates;
    // The minimum time between updates in milliseconds
    private long mTimeForUpdates;
    
    private double mLat; 
    private double mLng;
    private double mAlt;
    
    private int mCriteriaAccuracy;
  
    private String mMapType;
    private int mMapZoom;
    private int mMapSizeW;
    private int mMapSizeH;
    
    
    //GUIDELINE: please, preferentially, init all yours params names with "_", ex: int _flag, String _hello ...
    public jLocation(Controls _ctrls, long _Self, long _TimeForUpdates, long _DistanceForUpdates, int _CriteriaAccuracy, int _MapType) { //Add more others news "_xxx" params if needed!
       //super(_ctrls.activity);
       context   = _ctrls.activity;
       pascalObj = _Self;
       controls  = _ctrls;
       
       //Get the location manager
       mLocationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
       //Define the criteria how to select the location provider
       mCriteria = new Criteria();
       
       if (_CriteriaAccuracy == 0) {
          mCriteriaAccuracy = Criteria.ACCURACY_COARSE; //default::Network-based/wi-fi
       }else {
    	  mCriteriaAccuracy = Criteria.ACCURACY_FINE;  
       }
       
       switch(_MapType) { //mt, mt, mtHybrid
         case 0: mMapType = "roadmap"; break;
         case 1: mMapType = "satellite"; break;
         case 2: mMapType = "terrain"; break;
         case 3: mMapType = "hybrid"; break;
         default: mMapType = "roadmap";
       }
       
       /*
        * the Android Location Services periodically checks on your location using GPS, Cell-ID, 
        * and Wi-Fi to locate your device. When it does this,
        *  your Android phone will send back publicly broadcast Wi-Fi access points' Service set identifier (SSID) 
        *  and Media Access Control (MAC) data.
        *  ref: http://www.zdnet.com/blog/networking/how-google-and-everyone-else-gets-wi-fi-location-data/1664
        */
       
       mlistener = new MyLocationListener();
       
       mLat = 0.0; 
       mLng = 0.0;
       
       mTimeForUpdates = _TimeForUpdates;           //(long) (1000 * 60 * 1)/4; // 1 minute
       mDistanceForUpdates = _DistanceForUpdates;  //1; //meters
       
       mMapZoom = 14;
       mMapSizeW = 512;
       mMapSizeH = 512;
       
    }

    public void jFree() {
      //free local objects...
      mLocationManager = null;
      mCriteria = null;
      mlistener = null;    	
    }
    
  //write others [public] methods code here......
  //GUIDELINE: please, preferentially, init all yours params names with "_", ex: int _flag, String _hello ...
    
  public boolean StartTracker() {
        boolean result;
        
	    mCriteria.setAccuracy(mCriteriaAccuracy);                     
	    mCriteria.setCostAllowed(false);
	                                 
	    //get the best provider depending on the criteria
        mProvider = mLocationManager.getBestProvider(mCriteria, false);       

        //the last known location of this provider		 		 
        Location location = mLocationManager.getLastKnownLocation(mProvider);                    
                
        if (location != null) {
          mLat = location.getLatitude(); 
          mLng = location.getLongitude();
          mAlt = location.getAltitude();
          mAddress = GetAddress(mLat, mLng);          
          mlistener.onLocationChanged(location);
          result = true;
        }            
        else {
        	// Log.i("jLocation", "Wait... No Location Yet!!");                	        
        	 result = false;
        }    
        
        mLocationManager.requestLocationUpdates(mProvider, mTimeForUpdates, mDistanceForUpdates, mlistener);
        
        return result;
   }

   public void ShowLocationSouceSettings() {
	  Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
      context.startActivity(intent); 
   }   
   
   public void RequestLocationUpdates() {          	      
      mLocationManager.requestLocationUpdates(mProvider, mTimeForUpdates, mDistanceForUpdates, mlistener);
   } 	
       
   public void StopTracker() {  // finalize ....
      mlistener.RemoveUpdates(mLocationManager);
   }
    
   public void SetCriteriaAccuracy(int _accuracy) {
       if(_accuracy == 0){  //default...     	            
          mCriteria.setAccuracy(Criteria.ACCURACY_COARSE);   //less accuracy      
       }else { 
    	  mCriteria.setAccuracy(Criteria.ACCURACY_FINE); //high accuracy         
       }          
    }       
        
    public boolean IsGPSProvider() {
       return mLocationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
    }
    
    public boolean IsNetProvider() {
       return mLocationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
    }
    
    public void SetTimeForUpdates(long _time) { // millsecs 
      mTimeForUpdates = _time;
    }
    
    public void SetDistanceForUpdates(long _distance) { //meters
      mDistanceForUpdates = _distance;
    }
    
    public double GetLatitude() { 
      return mLat;
    }   
    
    public double GetLongitude() {
      return mLng;
    }   

    public double GetAltitude() {
      return mAlt;
    }   
        
    public boolean IsWifiEnabled() {
       WifiManager wifiManager = (WifiManager)this.context.getSystemService(Context.WIFI_SERVICE);
       return  wifiManager.isWifiEnabled();	
    }
    
    public void SetWifiEnabled(boolean _status) {
       WifiManager wifiManager = (WifiManager)this.context.getSystemService(Context.WIFI_SERVICE);             
       wifiManager.setWifiEnabled(_status);
    }
        
    //https://developers.google.com/maps/documentation/staticmaps
    public String GetGoogleMapsUrl(double _latitude, double _longitude) {        
      String url = "http://maps.googleapis.com/maps/api/staticmap?center="+_latitude + "," + _longitude+
                    "&zoom="+mMapZoom+"&size="+mMapSizeW+"x"+mMapSizeH+"&maptype="+mMapType+"&markers="+_latitude + "," + _longitude;          		                         
      return url;
    }
    
    public void SetMapWidth(int _mapwidth) {
	   mMapSizeW = _mapwidth;    	
    }
    
    public void SetMapHeight(int _mapheight) {
	  mMapSizeH= _mapheight;    	
    }
    
    public void SetMapZoom(int _mapzoom) {
      if (_mapzoom < 15) {	
	     mMapZoom = _mapzoom;
      }
      else {
    	 mMapZoom = 14;
      }      
    }
    
   public void SetMapType(int _maptype) {
	  switch(_maptype) {
		 case 0: mMapType= "roadmap"; break;
		 case 1: mMapType= "satellite"; break;
		 case 2: mMapType= "terrain"; break;
		 case 3: mMapType= "hybrid"; break;
		 default: mMapType= "roadmap";
	  }   		
    }

   public String GetAddress() {
	     return mAddress;
   }

    public String GetAddress(double _latitude, double _longitude) {
  	 
           Geocoder geocoder = new Geocoder(context, Locale.getDefault());
           // Get the current location from the input parameter list
           // Create a list to contain the result address
           List<Address> addresses = null;
           try {
               /*
                * Return 1 address.
                */
               addresses = geocoder.getFromLocation(_latitude, _longitude, 1);
           } catch (IOException e1) {
               e1.printStackTrace();
               return ("IO Exception trying to get address:" + e1);
           } catch (IllegalArgumentException e2) {
               // Error message to post in the log
               String errorString = "Illegal arguments passed to address service";
               e2.printStackTrace();
               return errorString;
           }
           // If the reverse geocode returned an address
           if (addresses != null && addresses.size() > 0) {
               // Get the first address
               Address address = addresses.get(0);
               /*
                * Format the first line of address (if available), city, and
                * country name.
                */
               String addressText = String.format(
                       "%s, %s, %s",
                       // If there's a street address, add it
                       address.getMaxAddressLineIndex() > 0 ? address
                               .getAddressLine(0) : "",
                       // Locality is usually a city
                       address.getLocality(),
                       // The country of the address
                       address.getCountryName());
               // Return the text
               return addressText;
           } else {
               return "No address found by the service: Note to the developers, If no address is found by google itself, there is nothing you can do about it. :(";
           }
    }
       
    private class MyLocationListener implements LocationListener {    	    	
    	
        @Override
        /*.*/public void onLocationChanged(Location location) {
             //Initialize the location fields
                          
             mLat = location.getLatitude();
             mLng = location.getLongitude();
             mAlt= location.getAltitude();
                         
             mLatitude= String.valueOf(mLat);
             mLongitude= String.valueOf(mLng);
             mAltitude= String.valueOf(mAlt);
             
             mAddress = GetAddress(mLat, mLng);
             
            // Log.i("jLocation", "Latitude: "+ mLatitude+ " ... Longitude: "+mLongitude+" ... Altitude: " + mAltitude);
                          
        	 controls.pOnLocationChanged(pascalObj,mLat,mLng,mAlt,mAddress);        		
        }

        @Override
        /*.*/public void onStatusChanged(String provider, int status, Bundle extras) {
           
        	switch (status) {
    		  case LocationProvider.OUT_OF_SERVICE:
    			 mStatus="Out of Service";
    		  break;
    		  case LocationProvider.TEMPORARILY_UNAVAILABLE:
    			  mStatus="Temporarily Unavailable";    			
    	      break;
    		  case LocationProvider.AVAILABLE:
    			 mStatus="Available";    		
              break;
    		}        	        	
        	//Log.i("jLocation", "mStatus: "+mStatus);
        	
        	controls.pOnLocationStatusChanged(pascalObj, status, provider, mStatus);
        }

        @Override
        /*.*/public void onProviderEnabled(String provider) {
        	//Log.i("jLocation", "Enabled: "+provider);
        	controls.pOnLocationProviderEnabled(pascalObj, provider);
        }
        
        @Override
        /*.*/public void onProviderDisabled(String provider) {        
        	///* this is called if/when the GPS is disabled in settings */
        	//Log.i("jLocation", "Disabled: "+provider);
        	controls.pOnLocationProviderDisabled(pascalObj, provider);        	
        }
                
        /*.*/public void RemoveUpdates(LocationManager lm) {
        	lm.removeUpdates(this);
        } 
    }
}

