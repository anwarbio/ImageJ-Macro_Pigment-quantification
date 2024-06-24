/* Macro to quantify pigmentation */

/* Reference: Book chapter “A non-destructive, image analysis method for 
evaluating pigmentation in iPSC derived retinal pigment epithelial cells”, 
Cell-Based Assays Using iPSCs for Drug Development and Testing - 2nd edition, 
Methods in Molecular Biology - Springer Protocols, 2024 */

/* Script by Dr. Anwar A. Palakkan, bioanwar@gmail.com */

//////////////////////////////////////////////////////////////////////////////////////////////////////

/* Creating directories */

print("\\Clear");  // Clear the log window

// Prompt user to select the input folder
inDir = getDirectory("Select the folder");
print("Input folder is " + inDir);

// Get the list of files in the input directory
list = getFileList(inDir);
length = list.length;

// Define and create the output directory
outDir = inDir + "processed/";
File.makeDirectory(outDir);
print("Output folder is " + outDir);

// Define and create directories for storing intermediate images
ROIImage = outDir + "ROIImage/"; 
SignalImage = outDir + "SignalImage/";
File.makeDirectory(ROIImage);
File.makeDirectory(SignalImage);

// Define the path for the results CSV file
WriteResult = outDir + "Results.csv";
f = File.open(WriteResult);

// Write the header line to the results CSV file
print(f, "Image,Background,Raw Intensity,Signal Mean,Area,IntDen,\n");

/* Looping through images */

for (j = 0; j < length; j++) { 
    if (endsWith(list[j], ".tif")) { 
        open(inDir + list[j]);  // Open the current image
        Title = getTitle();
        print("Processing image: " + Title);
        run("Clear Results");  // Erase any previous measurement results 

        /* Ask the user to identify the background */
        
        // Wait for the user to create a selection for the background
        waitForUser("Please create a selection to indicate the background, then click OK to proceed.");
        roiManager("Add");  // Add the selection to the ROI Manager

        roiManager("select", 0);  // Select the ROI
        Roi.setStrokeWidth(4);  // Set the ROI stroke width
        run("Flatten");  // Flatten the image to include the ROI
        saveAs("tiff", ROIImage + Title);  // Save the image with the ROI
        close();  // Close the current image

        run("Select None");  // Deselect any ROI

        /* Convert color image to grayscale & invert image */
        selectImage(Title);
        run("8-bit");  // Convert image to 8-bit grayscale
        run("Invert");  // Invert the grayscale image

        /* Processing the image */
        roiManager("select", 0);  // Select the background ROI
        Roi.setStrokeWidth(0);  // Remove the ROI stroke

        roiManager("Measure");  // Calculate the statistics of the ROI
        Background = getResult("Mean", 0);  // Get the background intensity from the ROI statistics
        print("Background Intensity is " + Background);
        run("Select None");  // Deselect any ROI

        selectImage(Title);  // Select the image
        run("Measure");  // Calculate the statistics of the image
        Int = getResult("Mean", 1);  // Get the total intensity from the image statistics
        print("Total Intensity is " + Int);
        run("Select None");  // Deselect the image

        selectImage(Title);  // Select the image
        run("Subtract...", "value=" + Background);  // Subtract background intensity from the image
        run("Measure");  // Calculate the statistics of the background reduced image 
        Sig = getResult("Mean", 2);  // Get the signal intensity from the image statistics
        print("Signal Intensity is " + Sig);

        Area = getResult("Area", 2);  // Get the area of the image
        IntDen = getResult("IntDen", 2);  // Get the integrated density from the image statistics

        saveAs("tiff", SignalImage + Title);  // Save the processed image

        /* Print results to file */
        print(f, Title + "," + Background + "," + Int + "," + Sig + "," + Area + "," + IntDen + ",\n");

        /* Close windows */
        close("ROI Manager");  // Close the ROI Manager
        run("Close");  // Close the current image
    } 
}

/* Close the results CSV file */
File.close(f);

/* Close all remaining windows */
run("Close All");
close("Results");

