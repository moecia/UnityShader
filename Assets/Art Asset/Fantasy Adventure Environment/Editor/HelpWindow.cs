using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace FAE
{
    public class HelpWindow : EditorWindow
    {
        //Window properties
        private static int width = 440;
        private static int height = 300;

        private bool isTabInstallation = true;
        private bool isTabGettingStarted = false;
        private bool isTabSupport = false;

        [MenuItem("Help/Fantasy Adventure Environment", false, 0)]
        public static void ShowWindow()
        {
            EditorWindow editorWindow = EditorWindow.GetWindow<HelpWindow>(false, "About", true);
            editorWindow.titleContent = new GUIContent("Help " + FAE_Core.INSTALLED_VERSION);
            editorWindow.autoRepaintOnSceneChange = true;

            //Open somewhat in the center of the screen
            editorWindow.position = new Rect((Screen.width) / 2f, (Screen.height) / 2f, width, height);

            //Fixed size
            editorWindow.maxSize = new Vector2(width, height);
            editorWindow.minSize = new Vector2(width, 200);

            Init();

            editorWindow.Show();

        }

        private void SetWindowHeight(float height)
        {
            this.maxSize = new Vector2(width, height);
            this.minSize = new Vector2(width, height);
        }

        //Store values in the volatile SessionState
        static void Init()
        {
            FAE_Core.GetRootFolder();
        }

        void OnGUI()
        {
            DrawHeader();

            GUILayout.Space(5);
            DrawTabs();
            GUILayout.Space(5);

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            if (isTabInstallation) DrawInstallation();
            if (isTabGettingStarted) DrawGettingStarted();
            if (isTabSupport) DrawSupport();

            //DrawActionButtons();

            EditorGUILayout.EndVertical();

            DrawFooter();

        }

        void DrawHeader()
        {
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("<b><size=24>Fantasy Adventure Environment</size></b>", Header);

            GUILayout.Label("Version: " + FAE_Core.INSTALLED_VERSION, Footer);
            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
        }

        void DrawTabs()
        {
            EditorGUILayout.BeginHorizontal();

            if (GUILayout.Toggle(isTabInstallation, "Installation", Tab))
            {
                isTabInstallation = true;
                isTabGettingStarted = false;
                isTabSupport = false;
            }

            if (GUILayout.Toggle(isTabGettingStarted, "Getting started", Tab))
            {
                isTabInstallation = false;
                isTabGettingStarted = true;
                isTabSupport = false;
            }

            if (GUILayout.Toggle(isTabSupport, "Support", Tab))
            {
                isTabInstallation = false;
                isTabGettingStarted = false;
                isTabSupport = true;
            }

            EditorGUILayout.EndHorizontal();
        }

        void DrawInstallation()
        {
            SetWindowHeight(335);

            EditorGUILayout.LabelField("Render pipeline conversion", EditorStyles.boldLabel);

#if !UNITY_2019_3_OR_NEWER

            EditorGUILayout.HelpBox("Universal Render Pipeline support requires Unity 2019.3.7f1 or newer", MessageType.Info);
#else
            if (UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset == null)
            {
                EditorGUILayout.HelpBox("No Scriptable Render Pipeline is currently active", MessageType.Warning);
            }

#if FAE_DEV
            EditorGUILayout.BeginHorizontal();
            {
                if (GUILayout.Button("<b><size=16>Built-in</size></b>\n<i>Amplify Shader Editor shaders</i>", Button))
                {
                    FAE_Core.InstallShaders(FAE_Core.ShaderInstallation.BuiltIn);
                }
#endif
                using (new EditorGUI.DisabledGroupScope(UnityEngine.Rendering.GraphicsSettings.renderPipelineAsset == null))
                {
                    if (GUILayout.Button("<b><size=16>Universal Render Pipeline</size></b>\n<i>Unpack Shader Graph shaders and URP materials</i>", Button))
                    {
                        FAE_Core.InstallShaders(FAE_Core.ShaderInstallation.UniversalRP);
                    }
                }
#if FAE_DEV
            }
            EditorGUILayout.EndHorizontal();
#endif

            EditorGUILayout.Space();

            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUILayout.HelpBox("Note: Grass shader for the URP is available on the Asset Store", MessageType.Info);
                if (GUILayout.Button("Open Asset Store", GUILayout.Height(40f), GUILayout.Width(120f)))
                {
                    Application.OpenURL("com.unity3d.kharma:content/143830");
                }
            }
#endif

        }

        void DrawGettingStarted()
        {
            SetWindowHeight(335);

            EditorGUILayout.HelpBox("Please view the documentation for further details about this package and its workings.", MessageType.Info);

            EditorGUILayout.Space();

            if (GUILayout.Button("<b><size=16>Online documentation</size></b>\n<i>Set up, best practices and troubleshooting</i>", Button))
            {
                Application.OpenURL(FAE_Core.DOC_URL + "#getting-started-3");
            }

        }

        void DrawSupport()
        {
            SetWindowHeight(350f);

            EditorGUILayout.BeginVertical(); //Support box

            EditorGUILayout.HelpBox("If you have any questions, or ran into issues, please get in touch!", MessageType.Info);

            EditorGUILayout.Space();

            //Buttons box
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("<b><size=12>Email</size></b>\n<i>Contact</i>", Button))
            {
                Application.OpenURL("mailto:contact@staggart.xyz");
            }
            if (GUILayout.Button("<b><size=12>Twitter</size></b>\n<i>Follow developments</i>", Button))
            {
                Application.OpenURL("https://twitter.com/search?q=staggart%20creations");
            }
            if (GUILayout.Button("<b><size=12>Forum</size></b>\n<i>Join the discussion</i>", Button))
            {
                Application.OpenURL(FAE_Core.FORUM_URL);
            }
            EditorGUILayout.EndHorizontal();//Buttons box

            EditorGUILayout.EndVertical(); //Support box
        }

        private void DrawActionButtons()
        {
            EditorGUILayout.Space();
            EditorGUILayout.BeginHorizontal();


            if (GUILayout.Button("<size=12>Rate</size>", Button))
                Application.OpenURL("https://www.assetstore.unity3d.com/en/#!/account/downloads/search=");

            if (GUILayout.Button("<size=12>Review</size>", Button))
                Application.OpenURL("");


            EditorGUILayout.EndHorizontal();
            EditorGUILayout.Space();
        }

        private void DrawFooter()
        {
            //EditorGUILayout.Space();
            EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
            EditorGUILayout.Space();
            GUILayout.Label("- Staggart Creations -", Footer);
        }

        #region Styles

        private static GUIStyle _Footer;
        public static GUIStyle Footer
        {
            get
            {
                if (_Footer == null)
                {
                    _Footer = new GUIStyle(EditorStyles.centeredGreyMiniLabel)
                    {
                        alignment = TextAnchor.MiddleCenter,
                        wordWrap = true,
                        fontSize = 12
                    };
                }

                return _Footer;
            }
        }

        private static GUIStyle _Button;
        public static GUIStyle Button
        {
            get
            {
                if (_Button == null)
                {
                    _Button = new GUIStyle(GUI.skin.button)
                    {
                        alignment = TextAnchor.MiddleLeft,
                        stretchWidth = true,
                        richText = true,
                        wordWrap = true,
                        padding = new RectOffset()
                        {
                            left = 14,
                            right = 14,
                            top = 8,
                            bottom = 8
                        }
                    };
                }

                return _Button;
            }
        }

        private static GUIStyle _Header;
        public static GUIStyle Header
        {
            get
            {
                if (_Header == null)
                {
                    _Header = new GUIStyle(GUI.skin.label)
                    {
                        richText = true,
                        alignment = TextAnchor.MiddleCenter,
                        wordWrap = true,
                        fontSize = 18,
                        fontStyle = FontStyle.Bold
                    };
                }

                return _Header;
            }
        }

        private static Texture _HelpIcon;
        public static Texture HelpIcon
        {
            get
            {
                if (_HelpIcon == null)
                {
                    _HelpIcon = EditorGUIUtility.FindTexture("d_UnityEditor.InspectorWindow");
                }
                return _HelpIcon;
            }
        }


        private static GUIStyle _Tab;
        public static GUIStyle Tab
        {
            get
            {
                if (_Tab == null)
                {
                    _Tab = new GUIStyle(EditorStyles.miniButtonMid)
                    {
                        alignment = TextAnchor.MiddleCenter,
                        stretchWidth = true,
                        richText = true,
                        wordWrap = true,
                        fontSize = 12,
                        fixedHeight = 30f,
                        fontStyle = FontStyle.Bold,
                        padding = new RectOffset()
                        {
                            left = 14,
                            right = 14,
                            top = 8,
                            bottom = 8
                        }
                    };
                }

                return _Tab;
            }
        }

        #endregion //Stylies
    }//Window Class
}