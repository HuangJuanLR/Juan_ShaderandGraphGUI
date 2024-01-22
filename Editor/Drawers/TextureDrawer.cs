/*
Copyright <2023> <HuangJuanLr>

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the “Software”), to deal in
the Software without restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

using System;
using UnityEditor;
using UnityEngine;

namespace JuanShaderEditor
{
    public class TextureDrawer : MaterialPropertyDrawer
    {
        private string extraPropName = "";
        Color targetColor;
        private bool conditional = false;
        private bool isHDR = false;

        private string keyword;

        public TextureDrawer()
        {
            
        }

        public TextureDrawer(string extraPropName)
        {
            if (extraPropName.Contains("#"))
            {
                conditional = true;
                this.extraPropName = extraPropName.Substring(1);
            }
            else
            {
                this.extraPropName = extraPropName;
                keyword = extraPropName;
            }
            
        }
        
        public TextureDrawer(string extraPropName, string extraParm)
        {
            if (extraPropName.Contains("#"))
            {
                conditional = true;
                this.extraPropName = extraPropName.Substring(1).Trim();
            }
            else
            {
                this.extraPropName = extraPropName;
            }

            if (extraParm.ToLower() == "hdr")
            {
                this.isHDR = extraParm.ToLower() == "hdr";
            }
            else
            {
                keyword = extraParm;
                this.isHDR = false;
            }
            
        }

        public TextureDrawer(string extraParm1, string extraParm2, string extraParm3)
        {
            if (extraParm1.Contains("#"))
            {
                conditional = true;
                this.extraPropName = extraParm1.Substring(1).Trim();
            }
            else
            {
                this.extraPropName = extraParm1;
            }
        
            keyword = extraParm2;
            this.isHDR = extraParm2.ToLower() == "hdr";
            
        }

        public override void OnGUI(Rect position, MaterialProperty property, String label, MaterialEditor materialEditor)
        {
            var value = property.textureValue;

            Material mat = materialEditor.target as Material;
            
            EditorGUILayout.Space(-EditorGUIUtility.standardVerticalSpacing - EditorGUIUtility.singleLineHeight);
            
            EditorGUI.BeginChangeCheck();
            
            EditorGUILayout.BeginHorizontal();
            {
                GUIContent prefixLabel = new GUIContent(label);

                if (mat.HasProperty(extraPropName) && !isHDR)
                {
                    var prop = MaterialEditor.GetMaterialProperty(new UnityEngine.Object[] { mat }, extraPropName);
                    if (!conditional)
                    {
                        materialEditor.TexturePropertySingleLine(prefixLabel, property, prop);
                    }
                    else
                    {
                        if (property.textureValue == null)
                        {
                            materialEditor.TexturePropertySingleLine(prefixLabel, property);
                        }
                        else
                        {
                            materialEditor.TexturePropertySingleLine(prefixLabel, property, prop);
                        }
                    }
                }
                else if (mat.HasProperty(extraPropName) && isHDR)
                {
                    targetColor = mat.GetColor(extraPropName);
                    
                    materialEditor.TexturePropertySingleLine(prefixLabel, property);
                    
                    Rect colorFieldRect = MaterialEditor.GetRectAfterLabelWidth(position);
                    GUIContent colorLabel = new GUIContent();

                    if (!conditional)
                    {
                        targetColor = EditorGUI.ColorField(colorFieldRect, colorLabel, targetColor, true, true, true);
                    }
                    else
                    {
                        if (property.textureValue != null)
                        {
                            targetColor = EditorGUI.ColorField(colorFieldRect, colorLabel, targetColor, true, true, true);
                        }
                    }
                    
                    
                    EditorGUILayout.Space(0);
                }
                else
                {
                    materialEditor.TexturePropertySingleLine(prefixLabel, property);
                }
            }
            EditorGUILayout.EndHorizontal();

            if (EditorGUI.EndChangeCheck())
            {
                Undo.RegisterCompleteObjectUndo(mat, "Texture Changed");

                if (mat.HasProperty(extraPropName) && isHDR)
                {
                    mat.SetColor(extraPropName, targetColor);
                }
                
                // If keyword is specified, enable/disable it based on texture value
                if (keyword != null && !mat.HasProperty(keyword))
                {
                    if (property.textureValue != null)
                    {
                        mat.EnableKeyword(keyword);
                    }
                    else
                    {
                        mat.DisableKeyword(keyword);
                    }
                    
                }
            }
        }
    }
}
