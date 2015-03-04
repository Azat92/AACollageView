# AACollageView
Custom UIView for displaying interactive collage from images

Have you ever been inspired by Google+ albums organisation? Photos are aligned exactly side by side with preserving tha aspect ratio. Now you can do that in your iOS application.

![alt demo](https://raw.githubusercontent.com/Azat92/AACollageView/master/demo.gif)

You can pass a varied number of images with different sizes and it is ok. There is support for preloaded images passing by array property or using delegate and providing arbitary URLs for downloading (under the hood is the [SDWebImage](https://github.com/rs/SDWebImage)). You set constraint either by width or height and another dimension is calculated automatically. Also margin between images is supported.

# Installation
Edit your PodFile to include the following line:

```
pod 'AACollageView', :podspec => 'https://raw.githubusercontent.com/Azat92/AACollageView/master/AACollageView.podspec'
```

Then import the main header.

```objectivec
#import <AACollageView.h>
```

Have a fun!

# Example Usage

Create from code or storyboard with ready images array

```objectivec
AACollageView *collageView = [[AACollageView alloc] initWithFrame:self.view.frame];//or IBOutlet
collageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
[self.view addSubview:collageView];
collageView.imagesArray = images;
[collageView setupCollageConstraintsWithMargin:3 height:NAN orWidth:self.view.frame.size.width refreshCollage:YES];
```

Using with delegate

```objectivec
- (NSInteger)imagesCountInCollageView:(AACollageView *)collageView {
    return self.imageSizes.count;
}

- (CGSize)collageView:(AACollageView *)collageView sizeForImageAtIndex:(NSUInteger)index {
    return [self.imageSizes[index] CGSizeValue];
}

- (NSURL *)collageView:(AACollageView *)collageView URLForImageAtIndex:(NSUInteger)index {
    //Could be URL from the web
    return self.imageURLS[index];
}

- (void)collageView:(AACollageView *)collageView didTapAtImageView:(UIImageView *)imageView atIndex:(NSUInteger)index {
    //do something
}
```

#Contact

Azat Almeev: azat.almeev@gmail.com
