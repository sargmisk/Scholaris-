# Scholaris

A decentralized marketplace for tutors and educators built on the Stacks blockchain, enabling credential verification, student success tracking, and professional networking.

## Overview

Scholaris is a smart contract-based platform that allows tutors to showcase their teaching credentials, document student success stories, and build professional networks with other educators. The platform emphasizes transparency, verification, and privacy controls for educational professionals.

## Features

### Core Functionality
- **Tutor Profiles**: Create comprehensive educator profiles with subject expertise and regional information
- **Credential Management**: Add and verify teaching credentials with cryptographic hashing
- **Success Tracking**: Document student achievements and learning outcomes
- **Professional Networking**: Connect with other qualified tutors and educators
- **Student Testimonials**: Collect and manage student feedback and endorsements

### Privacy & Access Control
- **Openness Levels**: Three-tier privacy system:
  - Public: Visible to everyone
  - Qualified Tutors: Visible only to networked educators
  - Private: Visible only to profile owner
- **Verification System**: Admin-controlled credential and tutor qualification verification

## Smart Contract Architecture

### Data Structures
- `tutor-profiles`: Core tutor information and qualifications
- `student-successes`: Documented student achievements
- `teaching-credentials`: Verified educational credentials
- `student-testimonials`: Peer and student recommendations
- `educational-networks`: Professional connections between tutors
- `subject-endorsements`: Subject-specific endorsement tracking

### Key Functions

#### Profile Management
- `create-tutor-profile`: Register as a tutor with expertise and regional info
- `get-tutor-profile`: Retrieve tutor profile information

#### Credential System
- `add-teaching-credential`: Submit teaching credentials for verification
- `verify-teaching-credential`: Admin function to verify credentials
- `get-teaching-credential`: Retrieve credential information

#### Success Tracking
- `document-student-success`: Record student achievements
- `get-student-success`: Retrieve success story details

#### Networking
- `send-network-request`: Request connection with another tutor
- `accept-network-request`: Accept incoming network requests
- `are-tutors-networked`: Check connection status between tutors

#### Testimonials
- `submit-student-testimonial`: Submit testimonial for a networked tutor
- `get-student-testimonial`: Retrieve testimonial information

## Getting Started

### Prerequisites
- Stacks blockchain access
- Clarity smart contract development environment
- STX tokens for transaction fees

### Deployment
1. Deploy the smart contract to the Stacks blockchain
2. The deployer becomes the contract owner with admin privileges
3. Configure the initial tutoring fee (default: 0.055%)

### Usage

#### For Tutors
1. Create your tutor profile with `create-tutor-profile`
2. Add your teaching credentials using `add-teaching-credential`
3. Document student successes with `document-student-success`
4. Network with other tutors through connection requests
5. Build your reputation through student testimonials

#### For Students
1. Connect with qualified tutors in your network
2. Submit testimonials for tutors you've worked with
3. View public tutor profiles and success stories

#### For Administrators
1. Verify teaching credentials with `verify-teaching-credential`
2. Qualify tutors using `qualify-tutor`
3. Manage platform fees with `update-tutoring-fee`

## Privacy Model

Scholaris implements a sophisticated privacy model with three openness levels:

- **Public (0)**: Information visible to all users
- **Qualified Tutors (1)**: Information visible only to networked, qualified tutors
- **Private (2)**: Information visible only to the content owner

This ensures that sensitive educational information is shared appropriately while maintaining professional standards.

## Security Features

- **Owner-only Functions**: Critical administrative functions restricted to contract owner
- **Network Verification**: Testimonials and endorsements require established tutor networks
- **Credential Hashing**: Teaching credentials stored with cryptographic hashes
- **Access Control**: Multi-level privacy controls for sensitive information

## Error Codes

- `u100`: Owner-only operation
- `u101`: Resource not found
- `u102`: Resource already exists
- `u103`: Unauthorized operation
- `u104`: Invalid openness level

## Contributing

Scholaris is designed to be a community-driven platform. Contributions are welcome for:
- Smart contract improvements
- Frontend development
- Documentation
- Testing and security audits

## Support

For questions, issues, or contributions, please refer to the project's issue tracker or contact the development team.
