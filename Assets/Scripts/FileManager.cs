using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine.UI;

using System.IO;

using SFB;


public class FileManager : MonoBehaviour
{
    private Texture2D openedImage;
    private Texture2D maskImage;

    private string savedImageFilepath = "";

    public Texture2D exampleImage;
    public Texture2D exampleMask;

    public RenderTexture RTT;
    public Camera RTTCam;

    public RawImage imageCanvas;
    public ColorPicker colorPicker;
    public Material recolorMat;

    public GameObject[] canvasElements;

    private Color pickedColor = Color.white;
    private bool colorPickerVisible = false;

    void OnAwake()
    {
        float width = openedImage.width;
        float height = openedImage.height;
        float screenWidth = Screen.width;
        imageCanvas.GetComponent<RectTransform>().sizeDelta = new Vector2( screenWidth, height*width/screenWidth);

        savedImageFilepath = Application.dataPath + "/saveImage.png";
    }

    // Start is called before the first frame update
    void Start()
    {
        savedImageFilepath = Application.dataPath + "/saveImage.png";
        
        colorPicker.onValueChanged.AddListener(color =>
		{

			//renderer.material.color = color;
            //Debug.Log(color.r + " - " + color.g + " - " + color.b);
            recolorMat.SetColor("_NewColor", color);
		});
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private Texture2D LoadPNG(string filePath) {
     
         Texture2D tex = null;
         byte[] fileData;
		  bool isLoaded = false;
     
         if (File.Exists(filePath))     {
             fileData = File.ReadAllBytes(filePath);
             tex = new Texture2D(2, 2);
             isLoaded = tex.LoadImage(fileData); //..this will auto-resize the texture dimensions.
         }
		 //Debug.Log(filePath + " is loaded: " + isLoaded);
         return tex;
     }

    private Texture2D LoadMask(string beautyImgPath)
    {
        string textureFileName = Path.GetFileNameWithoutExtension(beautyImgPath);
        string textureFileNameExtension = Path.GetExtension(beautyImgPath);
	    string directoryPath = Path.GetDirectoryName(beautyImgPath);

        string maskPath = directoryPath + "/" + textureFileName + "_mask" + textureFileNameExtension;

        Debug.Log("maskPath: " + maskPath);

        return LoadPNG(maskPath);
    } 

    public void pickExample()
    {
        openedImage = exampleImage;
        maskImage = exampleMask;

        setImageinGUI();
        setImageinMaterial();
    }

    public void openImage()
    {
        var extensions = new [] {
            new ExtensionFilter("Image Files", "png", "jpg", "jpeg" ),
        };
        var paths = StandaloneFileBrowser.OpenFilePanel("Open File", "", extensions, true);

        openedImage = LoadPNG(paths[0]);
        maskImage = LoadMask(paths[0]);


        setImageinGUI();
        setImageinMaterial();

    }

    private void setImageinGUI()
    {
        imageCanvas.texture = openedImage;
        float imgWidth = openedImage.width;
        float imgHeight = openedImage.height;
        float screenWidth = Screen.width;
        float screenHeight = Screen.height;
        Debug.Log("Loaded image resolution is: " + imgWidth + " x " + imgHeight);
        Debug.Log("Screen resolution is: " + screenWidth + " x " + screenHeight);

        //float imgRatio = screenHeight * imgWidth / screenWidth;
        float imgRatio = screenHeight / screenWidth;
        Debug.Log("Image Ratio is: " + imgRatio);
        Debug.Log("New size for image on screen is: " + screenWidth +" x " + imgRatio * imgHeight);

        imageCanvas.GetComponent<RectTransform>().sizeDelta = new Vector2( screenWidth, imgRatio * imgHeight);

        RTT = new RenderTexture( (int)imgWidth, (int)imgHeight, 24 );
        RTTCam.targetTexture = RTT;


    }

    private void setImageinMaterial()
    {
        recolorMat.SetTexture("_MainTex", openedImage);
        recolorMat.SetTexture("_MaskTex", maskImage);
    }

    public void showColorPicker()
    {
        if(colorPickerVisible == false)
        {
            colorPicker.gameObject.SetActive(true);
            colorPickerVisible = true;
        }else
        {
            colorPicker.gameObject.SetActive(false);
            colorPickerVisible = false;
        }
    }

    /*public void recolorImage(Color color)
    {
        recolorMat.SetTexture("_NewColor", maskImage);
    }*/

    //IEnumerator takeScreen(GameObject canvas)
    IEnumerator takeScreen()
    {
        // We should only read the screen buffer after rendering is complete
        yield return new WaitForSeconds(0.25f);
        ScreenCapture.CaptureScreenshot(savedImageFilepath);
        yield return new WaitForSeconds(0.25f);
        for(int i = 0; i < canvasElements.Length; i++)
        {
            canvasElements[i].SetActive(true);
        }
    }

    public void saveImage()
    {
        /*Debug.Log("savedImageFilepath: " + savedImageFilepath);
        Texture2D rawImageTexture = (Texture2D)imageCanvas.texture;
        SaveTextureToFile(rawImageTexture, savedImageFilepath);*/
        for(int i = 0; i < canvasElements.Length; i++)
        {
            canvasElements[i].SetActive(false);
        }
        StartCoroutine(takeScreen());
        //ScreenCapture.CaptureScreenshot(savedImageFilepath);
        //canvas.SetActive(true);
    }

    private void SaveTextureToFile (Texture2D texture, string filename) 
    { 
        System.IO.File.WriteAllBytes (filename, texture.EncodeToPNG());
    }    
}
