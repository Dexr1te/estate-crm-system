package com.crm.realestate.enums;

/**
 * The agreement a seller signed with the agency for a listing. A listing with none recorded has
 * no type at all (null), which is not the same as an open one.
 */
public enum MandateType {
    /** Only this agency may sell it, usually until an agreed date. */
    EXCLUSIVE,
    /** The seller may list it with other agencies as well. */
    OPEN
}
