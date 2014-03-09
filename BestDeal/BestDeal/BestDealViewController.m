//
//  BestDealViewController.m
//  BestDeal
//
//  Created by Thiago Rosa on 3/5/14.
//  Copyright (c) 2014 Pink Pointer. All rights reserved.
//

#import "BestDealViewController.h"

@interface BestDealViewController ()
@property (weak, nonatomic) IBOutlet UITextField *installment_number;
@property (weak, nonatomic) IBOutlet UITextField *installment_value;
@property (weak, nonatomic) IBOutlet UITextField *installment_total;
@property (weak, nonatomic) IBOutlet UITextField *downpayment_discount;
@property (weak, nonatomic) IBOutlet UITextField *downpayment_total;
@property (weak, nonatomic) IBOutlet UISwitch *payment_type;
@property (weak, nonatomic) IBOutlet UILabel *result;
@end

@implementation BestDealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.installment_number.delegate = self;
    self.installment_value.delegate = self;
    self.downpayment_discount.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    double inst_total = [[self.installment_number text] doubleValue] * [[self.installment_value text] doubleValue];
    double down_total = inst_total * (1 - ([[self.downpayment_discount text] doubleValue])/100);
    
    self.installment_total.text = [NSString stringWithFormat:@"%.2f", inst_total];
    self.downpayment_total.text = [NSString stringWithFormat:@"%.2f", down_total];
    self.result.text = @"";
    
    return YES;
}

- (IBAction)calculate:(id)sender {
    double inst_num = [[self.installment_number text] doubleValue];
    double inst_val = [[self.installment_value text] doubleValue];
    double inst_total = [[self.installment_total text] doubleValue];
    double down_disc = [[self.downpayment_discount text] doubleValue];
    double down_total = [[self.downpayment_total text] doubleValue];
    int type = [self.payment_type isOn];

    printf("%f x %f = %f\n", inst_num, inst_val, inst_total);
    printf("%f -> %f\n", down_disc, down_total);
    printf("type -> %d\n", type);
    
    double rate = [[self  class] RATEwithNPER: inst_num andPMT:(inst_total/inst_num) andPV:((-1)*inst_total*(1-(down_disc/100))) andTYPE:type];
    rate = rate*100;
    printf("\n\n\nRATE -> %f\n", rate);
    
    //[self.result setText:[NSString stringWithFormat:@"Interest Rate: %f", (rate*100)]];
    NSString *myResult = [NSString stringWithFormat:@"Monthly Interest Rate: %.2f%%", rate];
    self.result.text = myResult;
}

+ (void)calculate {
    
}

+ (double)PMTwithRATE: (double) rate
              andNPER: (double) nper
                andPV: (double) pv
                andFV: (double) fv
              andTYPE: (int) type {
    return (-pv * (pow(1 + rate, nper)) - fv) * rate / ((pow(1 + rate, nper) - 1) * (1 + rate * type));
}


+ (double)PVwithRATE: (double) rate
             andNPER: (double) nper
              andPMT: (double) pmt
               andFV: (double) fv
             andTYPE: (int) type {
    return (-pmt * ((pow(1 + rate, nper) - 1) / rate) * (1 + rate * type) - fv) / (pow(1 + rate, nper));
}


+ (double) FVwithRATE: (double) rate
              andNPER: (double) nper
               andPMT: (double) pmt
                andPV: (double) pv
              andTYPE: (int) type {
    //printf("[FV] rate = %f nper = %f pmt = %f pv = %f, type = %d ==> %f\n", rate, nper, pmt, pv, type, (-pv * pow(1 + rate, nper) - pmt * ((pow(1 + rate, nper) - 1) / rate) * (1 + rate * type)));
    return -pv * pow(1 + rate, nper) - pmt * ((pow(1 + rate, nper) - 1) / rate) * (1 + rate * type);
}

+ (double) RATEwithNPER: (double) nper
                 andPMT: (double) pmt
                  andPV: (double) pv
                andTYPE: (int) type {
    return [self RATEwithNPER: nper andPMT: pmt andPV: pv andFV: 0 andTYPE: type andGUESS: 0];
}

+ (double) RATEwithNPER: (double) nper
                 andPMT: (double) pmt
                  andPV: (double) pv
                  andFV: (double) fv
                andTYPE: (int) type
               andGUESS: (double) guess {
    double rate = guess;
    double current_fv = 0;
    double rate_increment = 0.5;
    
    for (int i = 0; i < 50; i++) {
        current_fv = [self FVwithRATE: rate andNPER: nper andPMT: pmt andPV: pv andTYPE: type];
        //printf("rate = %f fv = %f inc = %f\n", rate, current_fv, rate_increment);
        
        if (current_fv > fv) {
            rate -= rate_increment;
            rate_increment /= 2;
            rate += rate_increment;
            continue;
        }
        else {
            rate += rate_increment;
        }
    }
    
    return rate;
}

@end
