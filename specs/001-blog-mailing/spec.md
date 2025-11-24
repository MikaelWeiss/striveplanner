# Feature Specification: Blog Post Management and Mailing List

**Feature Branch**: `001-blog-mailing`
**Created**: 2025-10-24
**Status**: Draft
**Input**: User description: "the admin should be able to create a blog post and publish it without it being sent out to the mailing list. An admin should be able to select a date to send it out to the mailing list when creating a new blog as well as by editing an existing blog. When a blog is "scheduled" but hasn't been emailed out yet, that status should reflect in the admin sidebar. You should see in the sidebar when it's scheduled to send. If a blog has already been sent, you should see that in the sidebar as well as the date that it was sent out (may be different than the date it was published). The admin should be able to see a list somewhere of all the emails that have been enterred as well as if the emails have been verified or not. The admin should be able to create, update, and delete the emails that have been entered. The admin should be able to create a blog post and save it as a draft without publishing it. The admin should be able to unpublish a blog post (which will only remove it from the website, since it may have already been mailed out). If an admin unpublishes a blog post, it's status changes to draft and any scheduled send to email the blog out should be removed. When the date is hit for when a blog is scheduled, it should email everyone in the mailing list who has verified their email. The email that is sent out should be simple, follow the design patterns of the project, and have a way for the user to unsubscribe. If the user clicks on the unsubscribe link at the bottom of their email it should take them to a simple page explaining that they've been subscribed and change their status from "subscribed" to "unsubscribed" in the database. Emails should not send to emails with a "unsubscribed" status."

## User Scenarios & Testing

### User Story 1 - Blog Post Lifecycle Management (Priority: P1)

As an admin, I need to create, publish, and manage blog posts with complete control over their lifecycle states (draft, published, unpublished) so that I can prepare content in advance and control when it appears on the website.

**Why this priority**: Core content management functionality - without this, no other features (mailing, scheduling) can function. This represents the foundation of the entire feature.

**Independent Test**: Can be fully tested by creating a blog post, saving as draft, publishing it, viewing it on the website, then unpublishing it and verifying it's removed from the website but still exists in the admin system.

**Acceptance Scenarios**:

1. **Given** I am an admin user, **When** I create a new blog post and save it as a draft, **Then** the post is saved but not visible on the public website
2. **Given** I have a draft blog post, **When** I publish it, **Then** the post becomes visible on the public website
3. **Given** I have a published blog post, **When** I unpublish it, **Then** the post is removed from the public website but remains in the admin system with a "draft" status
4. **Given** I unpublish a blog post, **When** checking the post status, **Then** any scheduled email delivery is cancelled

---

### User Story 2 - Email Delivery Scheduling (Priority: P2)

As an admin, I need to schedule when a blog post should be emailed to the mailing list so that I can control the timing of email notifications independently from the publication date on the website.

**Why this priority**: Primary value-add for the mailing list integration - allows separation of web publishing from email marketing timing. Depends on P1 for blog post existence.

**Independent Test**: Can be tested independently by creating a published blog post, setting a scheduled email date, and verifying the post shows "scheduled" status in the sidebar with the correct date. Later verify that the email sends at the scheduled time.

**Acceptance Scenarios**:

1. **Given** I am creating a new blog post, **When** I set a scheduled email date and save, **Then** the post shows "scheduled" status with the selected date
2. **Given** I have an existing blog post, **When** I edit it and add a scheduled email date, **Then** the post status updates to "scheduled" with the selected date
3. **Given** I have a blog post with a scheduled email date, **When** I edit it and remove the scheduled date, **Then** the scheduled email is cancelled
4. **Given** the scheduled email date/time arrives, **When** the system processes scheduled emails, **Then** the email is sent to all verified subscribers and the post status updates to show "sent on [date]"
5. **Given** I publish a blog post without setting a scheduled email date, **When** viewing the post in the admin, **Then** the post does not appear as scheduled for email delivery

---

### User Story 3 - Mailing List Management (Priority: P2)

As an admin, I need to view and manage all mailing list subscriber emails so that I can maintain data quality and handle subscription management.

**Why this priority**: Essential for managing the subscriber base and ensuring email deliverability. Parallel importance to P2 email scheduling - both are needed for a complete mailing system.

**Independent Test**: Can be tested independently by navigating to the mailing list management view, adding new email addresses, verifying their verification status, editing email addresses, and deleting subscribers.

**Acceptance Scenarios**:

1. **Given** I am an admin user, **When** I navigate to the mailing list management page, **Then** I see a list of all subscriber emails with their verification and subscription status
2. **Given** I am viewing the mailing list, **When** I create a new subscriber entry, **Then** the new email is added to the list
3. **Given** I am viewing the mailing list, **When** I update a subscriber's email address, **Then** the changes are saved
4. **Given** I am viewing the mailing list, **When** I delete a subscriber, **Then** the subscriber is removed from the mailing list
5. **Given** I am viewing the mailing list, **When** I view a subscriber's details, **Then** I can see if their email has been verified and their subscription status (subscribed/unsubscribed)

---

### User Story 4 - Admin Sidebar Status Display (Priority: P3)

As an admin, I need to see the email delivery status of blog posts directly in the admin sidebar so that I can quickly understand the state of all posts without opening each one.

**Why this priority**: Enhances admin UX but not critical for core functionality. Posts can be managed without sidebar status indicators, though it's less convenient.

**Independent Test**: Can be tested by viewing the admin sidebar and verifying that different blog post states (scheduled, sent, not scheduled) are displayed correctly with appropriate dates.

**Acceptance Scenarios**:

1. **Given** a blog post has a scheduled email date in the future, **When** I view the admin sidebar, **Then** I see the post marked as "scheduled" with the scheduled date
2. **Given** a blog post has been emailed out, **When** I view the admin sidebar, **Then** I see the post marked as "sent" with the date it was sent
3. **Given** a blog post has no scheduled email, **When** I view the admin sidebar, **Then** the post does not show email scheduling information
4. **Given** a blog post's sent date differs from its published date, **When** I view the admin sidebar, **Then** both dates are clearly distinguishable

---

### User Story 5 - Email Notification with Unsubscribe (Priority: P2)

As a mailing list subscriber, I need to receive email notifications about new blog posts with the ability to unsubscribe so that I can control my email preferences.

**Why this priority**: Critical for compliance (CAN-SPAM, GDPR) and user trust. Must be implemented alongside email sending functionality.

**Independent Test**: Can be tested by triggering a scheduled email send, receiving the email as a test subscriber, clicking the unsubscribe link, and verifying the unsubscribe confirmation page appears and the subscription status updates.

**Acceptance Scenarios**:

1. **Given** a blog post's scheduled email date arrives, **When** the system sends emails, **Then** all verified subscribers with "subscribed" status receive the email
2. **Given** the system is sending scheduled emails, **When** processing the mailing list, **Then** subscribers with "unsubscribed" status do not receive the email
3. **Given** the system is sending scheduled emails, **When** processing the mailing list, **Then** subscribers with unverified emails do not receive the email
4. **Given** I receive a blog post notification email, **When** I view the email, **Then** it includes an unsubscribe link at the bottom
5. **Given** I click the unsubscribe link in an email, **When** the page loads, **Then** I see a confirmation message explaining I've been unsubscribed
6. **Given** I click the unsubscribe link in an email, **When** the unsubscribe is processed, **Then** my status in the database changes from "subscribed" to "unsubscribed"
7. **Given** I am an unsubscribed user, **When** future scheduled emails are sent, **Then** I do not receive any emails

---

### Edge Cases

- What happens when an admin tries to schedule an email date in the past?
- What happens if a blog post is unpublished after the scheduled email has already been sent?
- How does the system handle email delivery failures (bounces, invalid addresses)?
- What happens when an admin changes the scheduled email date after it's already been set?
- What happens if the system is down when a scheduled email should be sent?
- How does the system handle duplicate email addresses in the mailing list?
- What happens when a subscriber clicks an unsubscribe link multiple times?
- How does the system handle email addresses that were unsubscribed and then re-added to the mailing list?
- What happens to scheduled emails when a blog post is deleted?

## Requirements

### Functional Requirements

**Blog Post Management**:

- **FR-001**: Admins MUST be able to create a new blog post
- **FR-002**: Admins MUST be able to save a blog post as a draft without publishing it to the website
- **FR-003**: Admins MUST be able to publish a draft blog post, making it visible on the public website
- **FR-004**: Admins MUST be able to unpublish a published blog post, removing it from the public website while retaining it in the admin system
- **FR-005**: System MUST change a blog post's status to "draft" when it is unpublished
- **FR-006**: System MUST allow publishing a blog post without requiring it to be sent to the mailing list

**Email Scheduling**:

- **FR-007**: Admins MUST be able to set a scheduled email date when creating a new blog post
- **FR-008**: Admins MUST be able to set or modify a scheduled email date when editing an existing blog post
- **FR-009**: Admins MUST be able to remove a scheduled email date from a blog post
- **FR-010**: System MUST cancel any scheduled email delivery when a blog post is unpublished
- **FR-011**: System MUST automatically send emails to the mailing list when the scheduled date/time is reached
- **FR-012**: System MUST record the actual date an email was sent, which may differ from the publication date

**Status Display**:

- **FR-013**: Admin sidebar MUST display "scheduled" status for blog posts that have a future scheduled email date
- **FR-014**: Admin sidebar MUST display the scheduled email date for posts with scheduled emails
- **FR-015**: Admin sidebar MUST display "sent" status for blog posts that have already been emailed
- **FR-016**: Admin sidebar MUST display the actual sent date for posts that have been emailed
- **FR-017**: Admin sidebar MUST clearly distinguish between publication date and email sent date when they differ

**Mailing List Management**:

- **FR-018**: Admins MUST be able to view a list of all mailing list subscribers
- **FR-019**: Mailing list view MUST display each subscriber's email address
- **FR-020**: Mailing list view MUST display each subscriber's verification status (verified/unverified)
- **FR-021**: Mailing list view MUST display each subscriber's subscription status (subscribed/unsubscribed)
- **FR-022**: Admins MUST be able to create new subscriber entries
- **FR-023**: Admins MUST be able to update existing subscriber email addresses
- **FR-024**: Admins MUST be able to delete subscribers from the mailing list

**Email Delivery**:

- **FR-025**: System MUST send scheduled emails only to subscribers with verified email addresses
- **FR-026**: System MUST send scheduled emails only to subscribers with "subscribed" status
- **FR-027**: System MUST NOT send emails to subscribers with "unsubscribed" status
- **FR-028**: Emails MUST follow the existing design patterns of the project
- **FR-029**: Emails MUST include an unsubscribe link at the bottom

**Unsubscribe Flow**:

- **FR-030**: System MUST provide a unique unsubscribe link for each subscriber in sent emails
- **FR-031**: Unsubscribe links MUST direct users to a confirmation page
- **FR-032**: Unsubscribe confirmation page MUST display a message explaining the user has been unsubscribed
- **FR-033**: System MUST change subscriber status from "subscribed" to "unsubscribed" when the unsubscribe link is clicked
- **FR-034**: Unsubscribe action MUST persist in the database

### Key Entities

- **Blog Post**: Represents a blog article with content, title, publication status (draft/published), publication date, scheduled email date (optional), and email sent date (optional)
- **Mailing List Subscriber**: Represents an email address subscribed to the mailing list, including email address, verification status (verified/unverified), subscription status (subscribed/unsubscribed), and subscription metadata (dates, source)
- **Email Delivery Record**: Tracks when emails were sent for specific blog posts, including blog post reference, sent date/time, recipient count, and delivery status

## Success Criteria

### Measurable Outcomes

- **SC-001**: Admins can create, publish, and unpublish blog posts in under 2 minutes per post
- **SC-002**: Admins can schedule email delivery for a blog post in under 30 seconds
- **SC-003**: Scheduled emails are sent within 5 minutes of the scheduled time with 99% reliability
- **SC-004**: Admin sidebar accurately reflects blog post email status (scheduled/sent) for 100% of posts
- **SC-005**: Mailing list management page loads and displays all subscribers in under 2 seconds for lists up to 10,000 subscribers
- **SC-006**: Email delivery rate to verified subscribers reaches 95% or higher
- **SC-007**: Unsubscribe links work successfully for 100% of attempts
- **SC-008**: Users can complete the unsubscribe process in under 10 seconds with a single click
- **SC-009**: Zero emails are sent to unsubscribed or unverified email addresses
- **SC-010**: Blog post lifecycle transitions (draft → published → unpublished) complete instantly from user perspective (under 1 second)

## Assumptions

- Email verification for subscribers is handled by an existing system or will be implemented as part of this feature
- The project has an existing email delivery infrastructure or service that can be used for sending emails
- The admin sidebar referenced in the requirements exists and can be extended with new status displays
- The project's design patterns for emails include responsive HTML templates that will be adapted for blog notifications
- The scheduled email sending will use a background job system or cron-like scheduler
- Timezone handling for scheduled email dates will use the server's timezone or a configurable default timezone
- "Simple" email design means text-focused with minimal graphics, following transactional email best practices
- Subscriber verification happens through a double opt-in email confirmation flow (standard practice)
- The mailing list management interface will be part of the existing admin area
- Blog post content format (rich text, markdown, etc.) follows existing blog post patterns in the project
