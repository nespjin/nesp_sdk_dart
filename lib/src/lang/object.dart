/*
 * Copyright (c) 2023. NESP Technology Corporation. All rights reserved.
 *
 * This program is not free software; you can't redistribute it and/or modify it
 * without the permit of team manager.
 *
 * Unless required by applicable law or agreed to in writing.
 *
 * If you have any questions or if you find a bug,
 * please contact the author by email or ask for Issues.
 */

extension NullableObjectExtension<T extends Object> on T? {
  T or(T other) => this == null ? other : this!;

  R? castNullable<R>() => this == null ? null : this as R;

  R? tryCast<R>() => this is R ? this as R : null;
}

extension ObjectExtension<T extends Object> on T {
  R cast<R>() => this as R;
}
