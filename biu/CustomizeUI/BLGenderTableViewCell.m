//
//  BLGenderTableViewCell.m
//  biu
//
//  Created by Tony Wu on 5/26/15.
//  Copyright (c) 2015 BiuLove. All rights reserved.
//

#import "BLGenderTableViewCell.h"

#import "Masonry.h"

@interface BLGenderTableViewCell ()

@property (retain, nonatomic) UIView *maleView;
@property (retain, nonatomic) UIView *femaleView;
@property (retain, nonatomic) UIImageView *imageViewDivision;
@property (retain, nonatomic) UIImageView *imageViewMale;
@property (retain, nonatomic) UIImageView *imageViewFemale;
@property (retain, nonatomic) UIImage *imageMaleSelected;
@property (retain, nonatomic) UIImage *imageMaleUnselected;
@property (retain, nonatomic) UIImage *imageFemaleSelected;
@property (retain, nonatomic) UIImage *imageFemaleUnselected;

@property (retain, nonatomic) UIGestureRecognizer *tapMaleGestureRecognizer;
@property (retain, nonatomic) UIGestureRecognizer *tapFemaleGestureRecognizer;

@end

@implementation BLGenderTableViewCell

@synthesize gender = _gender;

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.title.text = NSLocalizedString(@"Choose your Gender", nil);
        
        _imageMaleSelected = [UIImage imageNamed:@"male_selected_icon_cn.png"];
        _imageMaleUnselected = [UIImage imageNamed:@"male_unselected_icon_cn.png"];
        _imageFemaleSelected = [UIImage imageNamed:@"female_selected_icon_cn.png"];
        _imageFemaleUnselected = [UIImage imageNamed:@"female_unselected_icon_cn.png"];
        
        _imageViewDivision = [[UIImageView alloc] init];
        _imageViewDivision.image = [UIImage imageNamed:@"division_icon.png"];
        [self.content addSubview:_imageViewDivision];
        
        _maleView = [[UIView alloc] init];
        _maleView.backgroundColor = [UIColor clearColor];
        _imageViewMale = [[UIImageView alloc] initWithFrame:_maleView.frame];
        [_maleView addSubview:_imageViewMale];
        [self.content addSubview:_maleView];
        
        _femaleView = [[UIView alloc] init];
        _femaleView.backgroundColor = [UIColor clearColor];
        _imageViewFemale = [[UIImageView alloc] initWithFrame:_femaleView.frame];
        [_femaleView addSubview:_imageViewFemale];
        [self.content addSubview:_femaleView];
        
        _tapMaleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMaleHandler:)];
        _tapMaleGestureRecognizer.delegate = self;
        [_maleView addGestureRecognizer:_tapMaleGestureRecognizer];
        
        _tapFemaleGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFemaleHandler:)];
        _tapFemaleGestureRecognizer.delegate = self;
        [_femaleView addGestureRecognizer:_tapFemaleGestureRecognizer];
        
        [self layout];
        
        // default is male
        _gender = BLGenderMale;
        _imageViewMale.image = _imageMaleSelected;
        _imageViewFemale.image = _imageFemaleUnselected;
    }
    return self;
}

#pragma mark - private
- (void)layout {
    [super layout];
    
    [_imageViewDivision mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_imageViewDivision.superview.mas_centerX);
        make.centerY.equalTo(_imageViewDivision.superview.mas_centerY);
        make.width.equalTo([NSNumber numberWithDouble:[BLGenernalDefinition resolutionForDevices:12.5f]]);
        make.height.equalTo([NSNumber numberWithDouble:[BLGenernalDefinition resolutionForDevices:72.5f]]);
    }];
    
    [_maleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_maleView.superview.mas_centerY);
        make.right.equalTo(_imageViewDivision.mas_left).with.offset([BLGenernalDefinition resolutionForDevices:-40.0f]);
        make.width.equalTo([NSNumber numberWithDouble:[BLGenernalDefinition resolutionForDevices:94.4f]]);
        make.height.equalTo([NSNumber numberWithDouble:[BLGenernalDefinition resolutionForDevices:141.5f]]);
    }];
    
    [_femaleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_femaleView.superview.mas_centerY);
        make.left.equalTo(_imageViewDivision.mas_right).with.offset([BLGenernalDefinition resolutionForDevices:40.0f]);
        make.width.equalTo([NSNumber numberWithDouble:[BLGenernalDefinition resolutionForDevices:94.4f]]);
        make.height.equalTo([NSNumber numberWithDouble:[BLGenernalDefinition resolutionForDevices:141.5f]]);
    }];
    
    [_imageViewMale mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_imageViewMale.superview);
    }];
    
    [_imageViewFemale mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_imageViewFemale.superview);
    }];
}

- (void)switchGender {
    switch (self.gender) {
        case BLGenderMale:
            _imageViewMale.image = _imageMaleUnselected;
            _imageViewFemale.image = _imageFemaleSelected;
            break;
        case BLGenderFemale:
            _imageViewFemale.image = _imageFemaleUnselected;
            _imageViewMale.image = _imageMaleSelected;
        default:
            break;
    }
}

#pragma mark - Gesture Handler
- (void)tapMaleHandler:(UITapGestureRecognizer *)recognizer {
    [self setGender:BLGenderMale];
}

- (void)tapFemaleHandler:(UITapGestureRecognizer *)recognizer {
    [self setGender:BLGenderFemale];
}

#pragma mark - Getting and Setting
- (void)setGender:(BLGender)gender {
    if (gender == BLGenderNone) {
        return;
    }
    
    if (_gender != gender) {
        [self switchGender];
        _gender = gender;
        if ([self.delegate respondsToSelector:@selector(tableViewCell:didChangeValue:)]) {
            [self.delegate tableViewCell:self didChangeValue:[NSNumber numberWithInteger:_gender]];
        }
    }
}

- (BLGender)gender {
    if (_gender == BLGenderNone) {
        _gender = BLGenderMale;
    }
    return _gender;
}

@end
