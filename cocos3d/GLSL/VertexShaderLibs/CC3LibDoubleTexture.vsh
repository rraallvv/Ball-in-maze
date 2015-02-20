/*
 * CC3LibDoubleTexture.vsh
 *
 * cocos3d 2.0.0
 * Author: Bill Hollings
 * Copyright (c) 2011-2014 The Brenwill Workshop Ltd. All rights reserved.
 * http://www.brenwill.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * http://en.wikipedia.org/wiki/MIT_License
 */

/**
 * This vertex shader library supports a material with up to two textures.
 *
 * This library declares and uses the following attribute and uniform variables:
 *   - attribute vec2	a_cc3TexCoord0;		// Vertex texture coordinate for texture unit 0.
 *   - attribute vec2	a_cc3TexCoord1;		// Vertex texture coordinate for texture unit 1.
 *
 * This library declares and outputs the following variables:
 *   - varying vec2		v_texCoord0;		// Fragment texture coordinates for texture unit 0.
 *   - varying vec2		v_texCoord1;		// Fragment texture coordinates for texture unit 1.
 */

attribute vec2		a_cc3TexCoord0;		/**< Vertex texture coordinate for texture unit 0. */
attribute vec2		a_cc3TexCoord1;		/**< Vertex texture coordinate for texture unit 1. */

varying vec2		v_texCoord0;		/**< Fragment texture coordinates for texture unit 0. */
varying vec2		v_texCoord1;		/**< Fragment texture coordinates for texture unit 1. */

/** Add textures to the vertex. Sets the v_texCoord0 varying.  */
void textureVertex() {
	v_texCoord0 = a_cc3TexCoord0;
	v_texCoord1 = a_cc3TexCoord1;
}

