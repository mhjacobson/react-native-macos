/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @format
 * @flow strict-local
 */

import type {ViewProps} from './ViewPropTypes';

import ViewNativeComponent from './ViewNativeComponent';
import TextAncestor from '../../Text/TextAncestor';
import warnOnce from '../../Utilities/warnOnce'; // [macOS #656]
import * as React from 'react';

export type Props = ViewProps;

/**
 * The most fundamental component for building a UI, View is a container that
 * supports layout with flexbox, style, some touch handling, and accessibility
 * controls.
 *
 * @see https://reactnative.dev/docs/view.html
 */
const View: React.AbstractComponent<
  ViewProps,
  React.ElementRef<typeof ViewNativeComponent>,
> = React.forwardRef((props: ViewProps, forwardedRef) => {
  // [macOS #656 Intercept props to warn about them going away
  if (props.acceptsKeyboardFocus !== undefined) {
    warnOnce(
      'deprecated-acceptsKeyboardFocus',
      '"acceptsKeyboardFocus" has been deprecated in favor of "focusable" and will be removed in a future version of react-native-macos',
    );
  }
  // macOS]

  return (
    <TextAncestor.Provider value={false}>
      <ViewNativeComponent {...props} ref={forwardedRef} />
    </TextAncestor.Provider>
  );
});

View.displayName = 'View';

module.exports = View;
