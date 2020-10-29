# Tile Collector

TileCollector is a project written in Matlab that manages the collection of mosaic-style images on a Nikon TE-2000xxx microscope and Ludl micropositioning stage in the Superfine and Hill labs at UNC-Chapel Hill. It draws from hardware-oriented projects also hosted on Github.


## Usage

At this time, the primary interface uses the command-line interface for initiating collections.

``` [MosaicTable,TiledImage] = tc_manualmosaic(ludl, calibum, XLim, YLim, OverlapFactor, FileOut)

Inputs
   - ludl: Handle to Ludl (run "ludl = stage_open_Ludl('COM3', 'BioPrecision2-LE2_Ludl5000')"
   - calibum: length scale in microns for 1 pixel, e.g. 0.150 um/pixel
   - XLim: 2-element vector denoting X-Limits in [mm], e.g. [-2 2] moves two mm to the left and collects through 2 mm to the right.
   - YLim: 2-element vector denoting Y-Limits in [mm], e.g. [-2 2] moves two mm up and collects through 2 mm down.
   - OverlapFactor: Defines the effective frame size. An OverlapFactor of "0.1" means that 10% of each image in X and Y will overlap with the next-most image to the right and below.
   - FileOut: filename for the outputted MosaicTable

Outputs
  - MosaicTable: same as the saved MosaicTable in the output file.
  - TiledImage: rudimentary assembled tiled mosaic image-matrix with no attempt to stitch the images together via cross-correlation.


## Example session

The general workflow is to:
1. Connect to the Ludl stage

  ```ludl = stage_open_Ludl('COM3', 'BioPrecision2-LE2_Ludl5000');

2. Open a video preview window. One is included in TileCollector...

  ```vid_impreview
3. Use the joystick to move to an interesting field-of-view.
4. Determine XLim and YLim based on the scaling factor that corresponds to the desired microscope objective magnification. Scaling factors can be found in Hill_Scope_LengthScales.csv
5. Close any opened camera preview windows.
6. Run tc_manualmosaic. Here's an example that will collect a "tall" mosaic that ranges from -2 mm to 2 mm in X and -5 to 5 mm in Y. It has zero overlap, and the output filename is "Tall_Mosaic".

``` [MosaicTable,T] = tc_manualmosaic(ludl, 1.204, [-2 2], [-4 4], 0, 'Tall_Mosaic');


